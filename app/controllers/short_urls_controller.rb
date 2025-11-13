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

    # Validate and sanitize the URL before redirecting
    safe_url = validated_url(@bookmark.url)

    if safe_url
      redirect_to safe_url, allow_other_host: true
    else
      redirect_to root_path, alert: "That bookmark has an invalid URL. Please contact the administrator."
    end
  end

  private

  # Validates and returns the URL if it's safe to redirect to, nil otherwise
  def validated_url(url)
    return nil if url.blank?

    begin
      uri = URI.parse(url)
      # Only allow HTTP and HTTPS protocols
      if uri.is_a?(URI::HTTP) || uri.is_a?(URI::HTTPS)
        url
      else
        nil
      end
    rescue URI::InvalidURIError
      nil
    end
  end
end
