class Album < ApplicationRecord
  belongs_to :user
  belongs_to :gallery, optional: true
  has_many :photos, dependent: :destroy
  has_many :videos, dependent: :destroy
  has_many :taggings, as: :taggable, dependent: :destroy
  has_many :tags, through: :taggings

  validates :title, presence: true
  validates :short_code, presence: true, uniqueness: true

  before_validation :generate_short_code, on: :create

  scope :public_albums, -> { where(is_public: true) }
  scope :private_albums, -> { where(is_public: false) }

  # Get the cover photo (either explicitly set or first photo)
  def cover_photo
    return nil if cover_photo_id.blank?
    Photo.find_by(id: cover_photo_id)
  end

  def cover_photo_or_default
    cover_photo || photos.first
  end

  # Add tags from a comma-separated string or array
  def tag_list=(tags_string)
    tag_names = tags_string.is_a?(String) ? tags_string.split(",").map(&:strip) : tags_string
    self.tags = tag_names.map { |name| Tag.find_or_create_by(name: name.downcase) }
  end

  def tag_list
    tags.map(&:name).join(", ")
  end

  private

  def generate_short_code
    return if short_code.present?

    loop do
      self.short_code = SecureRandom.alphanumeric(6)
      break unless Album.exists?(short_code: short_code)
    end
  end
end
