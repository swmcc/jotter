class ShortUrlsController < ApplicationController
  allow_unauthenticated_access

  def show
    @bookmark = Bookmark.find_by(short_code: params[:short_code])

    # Handle non-existent bookmark
    unless @bookmark
      redirect_to root_path, alert: "Nice try, but that short code doesn't exist. Maybe check your typing?"
      return
    end

    # Only show public bookmarks or bookmarks owned by current user
    unless @bookmark.is_public || (authenticated? && @bookmark.user == Current.session.user)
      redirect_to root_path, alert: "This bookmark is private. Either it doesn't exist, or it's none of your business."
      return
    end

    redirect_to @bookmark.url, allow_other_host: true
  end
end
