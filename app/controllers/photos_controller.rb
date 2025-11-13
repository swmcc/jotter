class PhotosController < ApplicationController
  allow_unauthenticated_access only: [:index, :show]
  before_action :set_photo, only: [:show, :edit, :update, :destroy]
  before_action :set_album, only: [:new, :create]

  def index
    if authenticated?
      @photos = Current.session.user.photos.includes(:tags).with_attached_image.order(created_at: :desc)
    else
      @photos = Photo.public_photos.includes(:tags).with_attached_image.order(created_at: :desc)
    end

    # Filter by tag if provided
    if params[:tag].present?
      tag = Tag.find_by(name: params[:tag])
      @photos = @photos.joins(:tags).where(tags: { id: tag.id }) if tag
    end

    # Search by title/description
    if params[:q].present?
      @photos = @photos.where("title ILIKE ? OR description ILIKE ?", "%#{params[:q]}%", "%#{params[:q]}%")
    end

    @tags = Tag.joins(:taggings).where(taggings: { taggable_type: "Photo" }).distinct
  end

  def show
    unless @photo && (authenticated? || @photo.is_public)
      redirect_to photos_path, alert: "Photo not found or is private."
      return
    end
  end

  def new
    @photo = Current.session.user.photos.build(album: @album)
  end

  def edit
  end

  def create
    @photo = Current.session.user.photos.build(photo_params)

    if @photo.save
      # Process image variants in background
      ProcessPhotoJob.perform_later(@photo.id)
      redirect_to @photo, notice: "Photo was successfully uploaded."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @photo.update(photo_params)
      redirect_to @photo, notice: "Photo was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @photo.destroy!
    redirect_to photos_path, notice: "Photo was successfully deleted."
  end

  private

  def set_photo
    @photo = if authenticated?
               Current.session.user.photos.find(params[:id])
             else
               Photo.public_photos.find(params[:id])
             end
  rescue ActiveRecord::RecordNotFound
    redirect_to photos_path, alert: "Photo not found."
  end

  def set_album
    @album = Current.session.user.albums.find(params[:album_id]) if params[:album_id].present?
  rescue ActiveRecord::RecordNotFound
    redirect_to albums_path, alert: "Album not found."
  end

  def photo_params
    params.require(:photo).permit(:title, :description, :is_public, :tag_list, :album_id, :image)
  end
end
