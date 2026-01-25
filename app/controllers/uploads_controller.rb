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

    # Build the photo
    @photo = Current.session.user.photos.build(photo_params)
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
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: { errors: @photo.errors.full_messages }, status: :unprocessable_entity }
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
      params.permit(:image, :title, :description, :is_public)
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
