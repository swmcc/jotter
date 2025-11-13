class ProcessPhotoJob < ApplicationJob
  queue_as :default

  def perform(photo_id)
    photo = Photo.find(photo_id)

    # Generate all variants to pre-process them
    # This will use libvips or ImageMagick to create the variants
    photo.thumbnail.processed
    photo.medium.processed
    photo.large.processed
  rescue ActiveRecord::RecordNotFound
    # Photo was deleted before job ran
    Rails.logger.info "Photo #{photo_id} not found, skipping variant processing"
  end
end
