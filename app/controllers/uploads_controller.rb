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
      @photo.title = @photo.image.filename.to_s.gsub(/\.\w+$/, '').humanize
    end

    if @photo.save
      # Process image variants in background
      ProcessPhotoJob.perform_later(@photo.id)
      redirect_to uploads_path, notice: "📸 #{@photo.title} uploaded!"
    else
      render :new, status: :unprocessable_entity
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
    params.require(:photo).permit(:image, :title, :description, :is_public)
  end
end
