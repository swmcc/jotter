class Photo < ApplicationRecord
  belongs_to :user
  belongs_to :album, optional: true
  has_one_attached :image
  has_many :taggings, as: :taggable, dependent: :destroy
  has_many :tags, through: :taggings

  validates :title, presence: true
  validates :short_code, presence: true, uniqueness: true
  validates :image, presence: true,
                    content_type: { in: ['image/jpeg', 'image/jpg', 'image/png', 'image/gif', 'image/webp'],
                                   message: 'must be a JPEG, PNG, GIF, or WebP image' },
                    size: { less_than: 10.megabytes, message: 'must be less than 10MB' }

  before_validation :generate_short_code, on: :create

  scope :public_photos, -> { where(is_public: true) }
  scope :private_photos, -> { where(is_public: false) }

  # Add tags from a comma-separated string or array
  def tag_list=(tags_string)
    tag_names = tags_string.is_a?(String) ? tags_string.split(",").map(&:strip) : tags_string
    self.tags = tag_names.map { |name| Tag.find_or_create_by(name: name.downcase) }
  end

  def tag_list
    tags.map(&:name).join(", ")
  end

  # Get image variants
  def thumbnail
    image.variant(resize_to_limit: [200, 200])
  end

  def medium
    image.variant(resize_to_limit: [800, 800])
  end

  def large
    image.variant(resize_to_limit: [1600, 1600])
  end

  private

  def generate_short_code
    return if short_code.present?

    loop do
      self.short_code = SecureRandom.alphanumeric(6)
      break unless Photo.exists?(short_code: short_code)
    end
  end
end
