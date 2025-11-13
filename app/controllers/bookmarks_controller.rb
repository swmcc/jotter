class BookmarksController < ApplicationController
  allow_unauthenticated_access only: [ :index, :show ]
  before_action :set_bookmark, only: [ :show, :edit, :update, :destroy ]

  def index
    # Show all bookmarks if logged in, only public if not
    if authenticated?
      @bookmarks = Current.session.user.bookmarks.includes(:tags).order(created_at: :desc)
    else
      @bookmarks = Bookmark.where(is_public: true).includes(:tags).order(created_at: :desc)
    end

    @tags = Tag.joins(:taggings).where(taggings: { taggable_type: "Bookmark", taggable_id: @bookmarks.pluck(:id) }).distinct.order(:name)

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
    # Allow public bookmarks to be viewed by anyone
    if !authenticated? && !@bookmark.is_public
      redirect_to bookmarks_path, alert: "This bookmark is private"
    end
  end

  def new
    @bookmark = Current.session.user.bookmarks.build(
      title: params[:title],
      url: params[:url],
      description: params[:description]
    )
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
    if authenticated?
      @bookmark = Current.session.user.bookmarks.find(params[:id])
    else
      @bookmark = Bookmark.find(params[:id])
    end
  end

  def bookmark_params
    params.require(:bookmark).permit(:title, :url, :description, :is_public, :tag_list)
  end
end
