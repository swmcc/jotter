class VideosController < ApplicationController
  allow_unauthenticated_access only: [ :index, :show ]
  before_action :set_video, only: [ :show, :edit, :update, :destroy ]
  before_action :set_album, only: [ :new, :create ]

  def index
    if authenticated?
      @videos = Current.session.user.videos.includes(:tags).with_attached_poster.order(created_at: :desc)
    else
      @videos = Video.public_videos.includes(:tags).with_attached_poster.order(created_at: :desc)
    end

    if params[:tag].present?
      tag = Tag.find_by(name: params[:tag])
      @videos = @videos.joins(:tags).where(tags: { id: tag.id }) if tag
    end

    if params[:q].present?
      @videos = @videos.where("title ILIKE ? OR description ILIKE ?", "%#{params[:q]}%", "%#{params[:q]}%")
    end

    @tags = Tag.joins(:taggings).where(taggings: { taggable_type: "Video" }).distinct
  end

  def show
    unless @video && (authenticated? || @video.is_public)
      redirect_to videos_path, alert: "Video not found or is private."
      nil
    end
  end

  def new
    @video = Current.session.user.videos.build(album: @album)
  end

  def edit
  end

  def create
    @video = Current.session.user.videos.build(video_params)

    if @video.save
      ProcessVideoJob.perform_later(@video.id)

      if @video.album
        redirect_to @video.album, notice: "Video uploaded! Processing in background..."
      else
        redirect_to videos_path, notice: "Video uploaded! Transcoding in background..."
      end
    else
      render :new, status: :unprocessable_content
    end
  end

  def update
    if @video.update(video_params)
      redirect_to @video, notice: "Video was successfully updated."
    else
      render :edit, status: :unprocessable_content
    end
  end

  def destroy
    @video.destroy!
    redirect_to videos_path, notice: "Video was successfully deleted."
  end

  private

  def set_video
    @video = if authenticated?
               Current.session.user.videos.find(params[:id])
    else
               Video.public_videos.find(params[:id])
    end
  rescue ActiveRecord::RecordNotFound
    redirect_to videos_path, alert: "Video not found."
  end

  def set_album
    @album = Current.session.user.albums.find(params[:album_id]) if params[:album_id].present?
  rescue ActiveRecord::RecordNotFound
    redirect_to albums_path, alert: "Album not found."
  end

  def video_params
    params.require(:video).permit(:title, :description, :is_public, :tag_list, :album_id, :original)
  end
end
