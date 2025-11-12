class ShortUrlsController < ApplicationController
  allow_unauthenticated_access

  def show
    @bookmark = Bookmark.find_by(short_code: params[:short_code])

    # Handle non-existent bookmark or private bookmark
    # Private bookmarks don't work via short URL for anyone, not even the owner
    unless @bookmark && @bookmark.is_public
      redirect_to root_path, alert: "Nice try, but that short code doesn't exist. Maybe check your typing?"
      return
    end

    redirect_to @bookmark.url, allow_other_host: true
  end
end
