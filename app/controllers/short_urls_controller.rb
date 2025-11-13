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

    # Validate URL is safe to redirect to (http/https only)
    # This is validated in the model, but double-check for security
    if valid_redirect_url?(@bookmark.url)
      redirect_to @bookmark.url, allow_other_host: true
    else
      redirect_to root_path, alert: "That bookmark has an invalid URL. Please contact the administrator."
    end
  end

  private

  def valid_redirect_url?(url)
    return false if url.blank?

    begin
      uri = URI.parse(url)
      uri.is_a?(URI::HTTP) || uri.is_a?(URI::HTTPS)
    rescue URI::InvalidURIError
      false
    end
  end
end
