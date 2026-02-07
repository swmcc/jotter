class UploadsController < ApplicationController
  before_action :require_authentication

  def index
    # Show all photos from current user's "Uploads" album (both public and private)
    uploads_album = Current.session.user.albums.find_by(title: "Uploads")

    if uploads_album
      @photos = uploads_album.photos
                             .includes(:tags)
                             .with_attached_image
                             .order(created_at: :desc)
    else
      @photos = Photo.none
    end
  end

  def new
    @photo = Photo.new
  end

  def create
    # Find or create the "Uploads" album for this user
    uploads_album = find_or_create_uploads_album

    # Build the photo, handling base64 uploads for iOS Shortcuts
    permitted_params = photo_params
    if params[:image_base64].present? && permitted_params[:image].blank?
      permitted_params = permitted_params.merge(image: handle_base64_image)
    end

    @photo = Current.session.user.photos.build(permitted_params)
    @photo.album = uploads_album

    # Use the uploaded filename as the title if no title provided
    if @photo.title.blank? && @photo.image.attached?
      @photo.title = @photo.image.filename.to_s.gsub(/\.\w+$/, "").humanize
    end

    if @photo.save
      # Process image variants in background
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

  private

  def find_or_create_uploads_album
    Current.session.user.albums.find_or_create_by(title: "Uploads") do |album|
      album.description = "Quick uploads"
      album.is_public = false
    end
  end

  def photo_params
    # Accept params nested under :photo (form submissions) or at root level (API calls)
    if params[:photo].present?
      params.require(:photo).permit(:image, :title, :description, :is_public)
    else
      params.permit(:image, :title, :description, :is_public, :image_base64, :filename, :content_type)
    end
  end

  # Handle base64-encoded image from JSON body (for iOS Shortcuts)
  def handle_base64_image
    return unless params[:image_base64].present?

    # Decode base64 data
    image_data = Base64.decode64(params[:image_base64])
    filename = params[:filename] || "upload_#{Time.current.to_i}.jpg"
    content_type = params[:content_type] || detect_content_type(image_data)

    # Create a temporary file
    tempfile = Tempfile.new([ "upload", File.extname(filename) ])
    tempfile.binmode
    tempfile.write(image_data)
    tempfile.rewind

    # Build an uploaded file object
    ActionDispatch::Http::UploadedFile.new(
      tempfile: tempfile,
      filename: filename,
      type: content_type
    )
  end

  def detect_content_type(data)
    # Check magic bytes for common image formats
    case data[0, 4].bytes
    when [ 0xFF, 0xD8, 0xFF, 0xE0 ], [ 0xFF, 0xD8, 0xFF, 0xE1 ]
      "image/jpeg"
    when [ 0x89, 0x50, 0x4E, 0x47 ]
      "image/png"
    when [ 0x47, 0x49, 0x46, 0x38 ]
      "image/gif"
    when [ 0x52, 0x49, 0x46, 0x46 ] # WebP starts with RIFF
      "image/webp"
    else
      "image/jpeg" # Default fallback
    end
  end

  def photo_json(photo)
    {
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
end
