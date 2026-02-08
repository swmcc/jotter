class ProcessVideoJob < ApplicationJob
  queue_as :default

  def perform(video_id)
    video = Video.find(video_id)

    Rails.logger.info "Processing video #{video_id}: #{video.title}"

    # Keep reference to tempfile object to prevent GC from deleting it
    @original_tempfile = download_to_tempfile(video.original)
    original_path = @original_tempfile.path
    transcoded_path = nil
    poster_path = nil

    begin
      movie = FFMPEG::Movie.new(original_path)

      unless movie.valid?
        Rails.logger.error "Invalid video file for video #{video_id}"
        video.update!(status: "failed")
        return
      end

      # Extract metadata
      video.update!(
        duration_seconds: movie.duration.to_i,
        width: movie.width,
        height: movie.height,
        file_size_bytes: movie.size
      )

      # Generate poster image
      poster_path = generate_poster(movie, original_path)
      if poster_path && File.exist?(poster_path)
        video.poster.attach(
          io: File.open(poster_path),
          filename: "#{video.short_code}_poster.jpg",
          content_type: "image/jpeg"
        )
      end

      # Transcode to web-friendly format
      transcoded_path = transcode_video(movie, original_path)
      if transcoded_path && File.exist?(transcoded_path)
        video.transcoded.attach(
          io: File.open(transcoded_path),
          filename: "#{video.short_code}.mp4",
          content_type: "video/mp4"
        )
      end

      video.update!(status: "ready")
      Rails.logger.info "Video #{video_id} processed successfully"

    rescue StandardError => e
      Rails.logger.error "Video processing failed for #{video_id}: #{e.message}"
      Rails.logger.error e.backtrace.first(10).join("\n")
      video.update!(status: "failed")
      raise
    ensure
      @original_tempfile&.unlink
      cleanup_tempfiles(transcoded_path, poster_path)
    end
  rescue ActiveRecord::RecordNotFound
    Rails.logger.info "Video #{video_id} not found, skipping processing"
  end

  private

  def download_to_tempfile(attachment)
    extension = File.extname(attachment.filename.to_s)
    tempfile = Tempfile.new([ "video_original", extension ])
    tempfile.binmode
    tempfile.write(attachment.download)
    tempfile.close
    tempfile  # Return the Tempfile object, not just the path
  end

  def generate_poster(movie, input_path)
    output_path = "#{input_path}_poster.jpg"

    # Screenshot at 1 second or 10% of duration (whichever is earlier)
    seek_time = [ 1, movie.duration * 0.1 ].min

    # Calculate resolution maintaining aspect ratio, max 1280 width
    width = [ movie.width, 1280 ].min
    height = (width.to_f / movie.width * movie.height).to_i
    # Ensure height is even (required by some codecs)
    height = height + 1 if height.odd?

    movie.screenshot(
      output_path,
      seek_time: seek_time,
      resolution: "#{width}x#{height}"
    )

    output_path
  rescue StandardError => e
    Rails.logger.error "Poster generation failed: #{e.message}"
    nil
  end

  def transcode_video(movie, input_path)
    output_path = "#{input_path}_transcoded.mp4"

    if needs_remux_only?(movie, input_path)
      # Just remux to MP4 container (no re-encoding, instant)
      Rails.logger.info "Video codecs OK, remuxing to MP4 container"
      remux_to_mp4(input_path, output_path)
    elsif already_optimal?(movie, input_path)
      # Already MP4 with H.264/AAC, skip entirely
      Rails.logger.info "Video already web-friendly, skipping transcode"
      return nil
    else
      # Full transcode needed
      Rails.logger.info "Transcoding video to H.264/AAC"
      full_transcode(movie, output_path)

      # If transcoded is larger than original, skip it
      if File.exist?(output_path) && File.size(output_path) > movie.size
        Rails.logger.info "Transcoded file larger than original, discarding"
        FileUtils.rm_f(output_path)
        return nil
      end
    end

    output_path if File.exist?(output_path)
  rescue StandardError => e
    Rails.logger.error "Video transcoding failed: #{e.message}"
    nil
  end

  def needs_remux_only?(movie, input_path)
    # H.264/AAC but not in MP4 container - just needs remuxing
    extension = File.extname(input_path).downcase
    return false if extension == ".mp4"

    has_web_codecs?(movie) && movie.width.to_i <= 1920
  end

  def already_optimal?(movie, input_path)
    extension = File.extname(input_path).downcase
    extension == ".mp4" && has_web_codecs?(movie) && movie.width.to_i <= 1920
  end

  def has_web_codecs?(movie)
    h264_codecs = %w[h264 avc1]
    aac_codecs = %w[aac]

    video_ok = h264_codecs.include?(movie.video_codec&.downcase)
    audio_ok = movie.audio_codec.nil? || aac_codecs.include?(movie.audio_codec&.downcase)

    video_ok && audio_ok
  end

  def remux_to_mp4(input_path, output_path)
    # Copy streams without re-encoding, just change container
    system(
      "ffmpeg", "-y", "-i", input_path,
      "-c", "copy",
      "-movflags", "+faststart",
      output_path
    )
  end

  def full_transcode(movie, output_path)
    options = {
      video_codec: "libx264",
      audio_codec: "aac",
      custom: %w[
        -preset fast
        -crf 28
        -movflags +faststart
        -vf scale='min(1920,iw)':-2
        -pix_fmt yuv420p
      ]
    }

    movie.transcode(output_path, options)
  end

  def cleanup_tempfiles(*paths)
    paths.compact.each do |path|
      FileUtils.rm_f(path) if path && File.exist?(path)
    end
  end
end
