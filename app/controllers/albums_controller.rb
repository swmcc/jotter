class AlbumsController < ApplicationController
  allow_unauthenticated_access only: [:index, :show]
  before_action :set_album, only: [:show, :edit, :update, :destroy]
  before_action :set_gallery, only: [:new, :create]

  def index
    if authenticated?
      @albums = Current.session.user.albums.includes(:tags, :photos).order(created_at: :desc)
    else
      @albums = Album.public_albums.includes(:tags, :photos).order(created_at: :desc)
    end

    # Filter by tag if provided
    if params[:tag].present?
      tag = Tag.find_by(name: params[:tag])
      @albums = @albums.joins(:tags).where(tags: { id: tag.id }) if tag
    end

    # Search by title/description
    if params[:q].present?
      @albums = @albums.where("title ILIKE ? OR description ILIKE ?", "%#{params[:q]}%", "%#{params[:q]}%")
    end

    @tags = Tag.joins(:taggings).where(taggings: { taggable_type: "Album" }).distinct
  end

  def show
    unless @album && (authenticated? || @album.is_public)
      redirect_to albums_path, alert: "Album not found or is private."
      return
    end

    @photos = @album.photos.includes(:tags).order(created_at: :desc)
  end

  def new
    @album = Current.session.user.albums.build(gallery: @gallery)
  end

  def edit
  end

  def create
    @album = Current.session.user.albums.build(album_params)

    if @album.save
      redirect_to @album, notice: "Album was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @album.update(album_params)
      redirect_to @album, notice: "Album was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @album.destroy!
    redirect_to albums_path, notice: "Album was successfully deleted."
  end

  private

  def set_album
    @album = if authenticated?
               Current.session.user.albums.find(params[:id])
             else
               Album.public_albums.find(params[:id])
             end
  rescue ActiveRecord::RecordNotFound
    redirect_to albums_path, alert: "Album not found."
  end

  def set_gallery
    @gallery = Current.session.user.galleries.find(params[:gallery_id]) if params[:gallery_id].present?
  rescue ActiveRecord::RecordNotFound
    redirect_to galleries_path, alert: "Gallery not found."
  end

  def album_params
    params.require(:album).permit(:title, :description, :is_public, :tag_list, :cover_photo_id, :gallery_id)
  end
end
