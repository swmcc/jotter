class BookmarksController < ApplicationController
  before_action :set_bookmark, only: [:show, :edit, :update, :destroy]

  def index
    @bookmarks = Current.session.user.bookmarks.includes(:tags).order(created_at: :desc)
    @tags = Tag.joins(:taggings).where(taggings: { taggable_type: 'Bookmark', taggable_id: @bookmarks.pluck(:id) }).distinct.order(:name)

    # Filter by tag if provided
    if params[:tag].present?
      @bookmarks = @bookmarks.joins(:tags).where(tags: { name: params[:tag] })
    end

    # Search if query provided
    if params[:q].present?
      @bookmarks = @bookmarks.where("title ILIKE ? OR description ILIKE ? OR url ILIKE ?",
                                     "%#{params[:q]}%", "%#{params[:q]}%", "%#{params[:q]}%")
    end
  end

  def show
  end

  def new
    @bookmark = Current.session.user.bookmarks.build
  end

  def create
    @bookmark = Current.session.user.bookmarks.build(bookmark_params)

    if @bookmark.save
      redirect_to bookmarks_path, notice: "Bookmark created successfully"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @bookmark.update(bookmark_params)
      redirect_to bookmark_path(@bookmark), notice: "Bookmark updated successfully"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @bookmark.destroy
    redirect_to bookmarks_path, notice: "Bookmark deleted"
  end

  private

  def set_bookmark
    @bookmark = Current.session.user.bookmarks.find(params[:id])
  end

  def bookmark_params
    params.require(:bookmark).permit(:title, :url, :description, :is_public, :tag_list)
  end
end
