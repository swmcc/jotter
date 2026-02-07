class GalleriesController < ApplicationController
  allow_unauthenticated_access only: [ :index, :show ]
  before_action :set_gallery, only: [ :show, :edit, :update, :destroy ]

  def index
    if authenticated?
      @galleries = Current.session.user.galleries.includes(:tags).order(created_at: :desc)
    else
      @galleries = Gallery.public_galleries.includes(:tags).order(created_at: :desc)
    end

    # Filter by tag if provided
    if params[:tag].present?
      tag = Tag.find_by(name: params[:tag])
      @galleries = @galleries.joins(:tags).where(tags: { id: tag.id }) if tag
    end

    # Search by title/description
    if params[:q].present?
      @galleries = @galleries.where("title ILIKE ? OR description ILIKE ?", "%#{params[:q]}%", "%#{params[:q]}%")
    end

    @tags = Tag.joins(:taggings).where(taggings: { taggable_type: "Gallery" }).distinct
  end

  def show
    unless @gallery && (authenticated? || @gallery.is_public)
      redirect_to galleries_path, alert: "Gallery not found or is private."
      return
    end

    @albums = @gallery.albums.includes(:photos).order(created_at: :desc)
  end

  def new
    @gallery = Current.session.user.galleries.build
  end

  def edit
  end

  def create
    @gallery = Current.session.user.galleries.build(gallery_params)

    if @gallery.save
      redirect_to @gallery, notice: "Gallery was successfully created."
    else
      render :new, status: :unprocessable_content
    end
  end

  def update
    if @gallery.update(gallery_params)
      redirect_to @gallery, notice: "Gallery was successfully updated."
    else
      render :edit, status: :unprocessable_content
    end
  end

  def destroy
    @gallery.destroy!
    redirect_to galleries_path, notice: "Gallery was successfully deleted."
  end

  private

  def set_gallery
    @gallery = if authenticated?
                 Current.session.user.galleries.find(params[:id])
    else
                 Gallery.public_galleries.find(params[:id])
    end
  rescue ActiveRecord::RecordNotFound
    redirect_to galleries_path, alert: "Gallery not found."
  end

  def gallery_params
    params.require(:gallery).permit(:title, :description, :is_public, :tag_list, :cover_photo_id)
  end
end
