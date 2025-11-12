class Bookmark < ApplicationRecord
  belongs_to :user
  has_many :taggings, as: :taggable, dependent: :destroy
  has_many :tags, through: :taggings

  validates :title, presence: true
  validates :url, presence: true, format: { with: URI::DEFAULT_PARSER.make_regexp(%w[http https]), message: "must be a valid URL" }
  validates :short_code, presence: true, uniqueness: true

  before_validation :generate_short_code, on: :create
  before_validation :normalize_url

  scope :public_bookmarks, -> { where(is_public: true) }
  scope :private_bookmarks, -> { where(is_public: false) }

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
      break unless Bookmark.exists?(short_code: short_code)
    end
  end

  def normalize_url
    return if url.blank?

    # Add protocol if missing
    self.url = "https://#{url}" unless url.match?(%r{\Ahttps?://})
  end
end
