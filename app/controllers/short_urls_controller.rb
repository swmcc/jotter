class ShortUrlsController < ApplicationController
  allow_unauthenticated_access

  def show
    @bookmark = Bookmark.find_by!(short_code: params[:short_code])

    # Only show public bookmarks or bookmarks owned by current user
    unless @bookmark.is_public || (authenticated? && @bookmark.user == Current.session.user)
      redirect_to root_path, alert: "Bookmark not found or is private"
      return
    end

    redirect_to @bookmark.url, allow_other_host: true
  end
end
