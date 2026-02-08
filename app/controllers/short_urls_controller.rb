class ShortUrlsController < ApplicationController
  allow_unauthenticated_access

  def show
    @bookmark = Bookmark.find_by(short_code: params[:short_code])

    unless @bookmark
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

  def show_media
    # Try to find photo, video, album, or gallery by short_code
    item = Photo.find_by(short_code: params[:short_code]) ||
           Video.find_by(short_code: params[:short_code]) ||
           Album.find_by(short_code: params[:short_code]) ||
           Gallery.find_by(short_code: params[:short_code])

    unless item
      redirect_to root_path, alert: "Nice try, but that doesn't exist. Maybe check your typing?"
      return
    end

    # For photos, serve the actual image for Slack/social media previews
    if item.is_a?(Photo)
      redirect_to rails_blob_path(item.image, disposition: "inline"), allow_other_host: false
    # For videos, serve the transcoded video (or original if not ready)
    elsif item.is_a?(Video)
      video_blob = item.ready? && item.transcoded.attached? ? item.transcoded : item.original
      redirect_to rails_blob_path(video_blob, disposition: "inline"), allow_other_host: false
    # For albums and galleries, redirect to their show pages
    elsif item.is_a?(Album)
      redirect_to album_path(item)
    elsif item.is_a?(Gallery)
      redirect_to gallery_path(item)
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
