class UploadsController < ApplicationController
  before_action :require_authentication

  VIDEO_CONTENT_TYPES = %w[
    video/mp4
    video/quicktime
    video/x-msvideo
    video/mpeg
    video/webm
    video/x-m4v
    video/x-matroska
  ].freeze

  IMAGE_CONTENT_TYPES = %w[
    image/jpeg
    image/jpg
    image/png
    image/gif
    image/webp
  ].freeze

  def index
    uploads_album = Current.session.user.albums.find_by(title: "Uploads")

    if uploads_album
      @photos = uploads_album.photos
                             .includes(:tags)
                             .with_attached_image
                             .order(created_at: :desc)
      @videos = uploads_album.videos
                             .includes(:tags)
                             .with_attached_poster
                             .order(created_at: :desc)
    else
      @photos = Photo.none
      @videos = Video.none
    end
  end

  def new
    @photo = Photo.new
  end

  def create
    uploads_album = find_or_create_uploads_album

    # Handle base64 uploads
    file = if params[:file_base64].present?
             handle_base64_file
    elsif params[:image_base64].present?
             handle_base64_file(params[:image_base64], params[:filename], params[:content_type])
    elsif params[:video_base64].present?
             handle_base64_file(params[:video_base64], params[:filename], params[:content_type])
    elsif params.dig(:photo, :image).present?
             params[:photo][:image]
    elsif params.dig(:video, :original).present?
             params[:video][:original]
    elsif params[:image].present?
             params[:image]
    elsif params[:video].present?
             params[:video]
    end

    content_type = file&.content_type || params[:content_type]

    if video_content_type?(content_type)
      create_video(file, uploads_album)
    else
      create_photo(file, uploads_album)
    end
  end

  private

  def create_photo(file, uploads_album)
    permitted = photo_params
    permitted = permitted.merge(image: file) if file && permitted[:image].blank?

    @photo = Current.session.user.photos.build(permitted)
    @photo.album = uploads_album

    if @photo.title.blank? && @photo.image.attached?
      @photo.title = @photo.image.filename.to_s.gsub(/\.\w+$/, "").humanize
    end

    if @photo.save
      ProcessPhotoJob.perform_later(@photo.id)

      respond_to do |format|
        format.html { redirect_to uploads_path, notice: "📸 #{@photo.title} uploaded!" }
        format.json { render json: photo_json(@photo), status: :created }
      end
    else
      respond_to do |format|
        format.html { render :new, status: :unprocessable_content }
        format.json { render json: { errors: @photo.errors.full_messages }, status: :unprocessable_content }
      end
    end
  end

  def create_video(file, uploads_album)
    permitted = video_params
    permitted = permitted.merge(original: file) if file && permitted[:original].blank?

    @video = Current.session.user.videos.build(permitted)
    @video.album = uploads_album

    if @video.title.blank? && @video.original.attached?
      @video.title = @video.original.filename.to_s.gsub(/\.\w+$/, "").humanize
    end

    if @video.save
      ProcessVideoJob.perform_later(@video.id)

      respond_to do |format|
        format.html { redirect_to uploads_path, notice: "🎬 #{@video.title} uploaded! Transcoding..." }
        format.json { render json: video_json(@video), status: :created }
      end
    else
      respond_to do |format|
        format.html { render :new, status: :unprocessable_content }
        format.json { render json: { errors: @video.errors.full_messages }, status: :unprocessable_content }
      end
    end
  end

  def find_or_create_uploads_album
    Current.session.user.albums.find_or_create_by(title: "Uploads") do |album|
      album.description = "Quick uploads"
      album.is_public = false
    end
  end

  def photo_params
    if params[:photo].present?
      params.require(:photo).permit(:image, :title, :description, :is_public)
    else
      params.permit(:image, :title, :description, :is_public)
    end
  end

  def video_params
    if params[:video].present?
      params.require(:video).permit(:original, :title, :description, :is_public)
    else
      params.permit(:original, :title, :description, :is_public)
    end
  end

  def handle_base64_file(base64_data = nil, filename = nil, content_type = nil)
    base64_data ||= params[:file_base64]
    return unless base64_data.present?

    file_data = Base64.decode64(base64_data)
    filename ||= params[:filename] || "upload_#{Time.current.to_i}"
    content_type ||= params[:content_type] || detect_content_type(file_data)

    # Add extension if missing
    unless filename.include?(".")
      ext = extension_for_content_type(content_type)
      filename = "#{filename}#{ext}"
    end

    tempfile = Tempfile.new([ "upload", File.extname(filename) ])
    tempfile.binmode
    tempfile.write(file_data)
    tempfile.rewind

    ActionDispatch::Http::UploadedFile.new(
      tempfile: tempfile,
      filename: filename,
      type: content_type
    )
  end

  def detect_content_type(data)
    bytes = data[0, 12].bytes

    # Video formats
    return "video/mp4" if bytes[4..7] == [ 0x66, 0x74, 0x79, 0x70 ] # ftyp
    return "video/quicktime" if bytes[4..11] == [ 0x66, 0x74, 0x79, 0x70, 0x71, 0x74, 0x20, 0x20 ] # ftyp qt
    return "video/webm" if bytes[0..3] == [ 0x1A, 0x45, 0xDF, 0xA3 ] # EBML header
    return "video/x-matroska" if bytes[0..3] == [ 0x1A, 0x45, 0xDF, 0xA3 ] # MKV also uses EBML
    return "video/avi" if bytes[0..3] == [ 0x52, 0x49, 0x46, 0x46 ] && bytes[8..11] == [ 0x41, 0x56, 0x49, 0x20 ]

    # Image formats
    return "image/jpeg" if bytes[0..2] == [ 0xFF, 0xD8, 0xFF ]
    return "image/png" if bytes[0..3] == [ 0x89, 0x50, 0x4E, 0x47 ]
    return "image/gif" if bytes[0..3] == [ 0x47, 0x49, 0x46, 0x38 ]
    return "image/webp" if bytes[0..3] == [ 0x52, 0x49, 0x46, 0x46 ] && data[8..11] == "WEBP"

    "application/octet-stream"
  end

  def extension_for_content_type(content_type)
    case content_type
    when "video/mp4" then ".mp4"
    when "video/quicktime" then ".mov"
    when "video/webm" then ".webm"
    when "video/x-matroska" then ".mkv"
    when "video/mpeg" then ".mpeg"
    when "video/x-msvideo" then ".avi"
    when "image/jpeg" then ".jpg"
    when "image/png" then ".png"
    when "image/gif" then ".gif"
    when "image/webp" then ".webp"
    else ""
    end
  end

  def video_content_type?(content_type)
    VIDEO_CONTENT_TYPES.include?(content_type)
  end

  def photo_json(photo)
    {
      type: "photo",
      photo: {
        id: photo.id,
        short_code: photo.short_code,
        short_url: media_short_url_url(photo.short_code),
        title: photo.title,
        description: photo.description,
        is_public: photo.is_public,
        created_at: photo.created_at.iso8601
      }
    }
  end

  def video_json(video)
    {
      type: "video",
      video: {
        id: video.id,
        short_code: video.short_code,
        short_url: media_short_url_url(video.short_code),
        title: video.title,
        description: video.description,
        is_public: video.is_public,
        status: video.status,
        created_at: video.created_at.iso8601
      }
    }
  end
end
