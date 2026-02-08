class Video < ApplicationRecord
  belongs_to :user
  belongs_to :album, optional: true

  has_one_attached :original
  has_one_attached :transcoded
  has_one_attached :poster

  has_many :taggings, as: :taggable, dependent: :destroy
  has_many :tags, through: :taggings

  validates :title, presence: true
  validates :short_code, presence: true, uniqueness: true
  validate :original_presence
  validate :original_format
  validate :original_size

  before_validation :generate_short_code, on: :create

  scope :public_videos, -> { where(is_public: true) }
  scope :private_videos, -> { where(is_public: false) }

  ALLOWED_FORMATS = %w[
    video/mp4
    video/quicktime
    video/x-msvideo
    video/mpeg
    video/webm
    video/x-m4v
    video/x-matroska
  ].freeze

  MAX_SIZE = 500.megabytes

  def tag_list=(tags_string)
    tag_names = tags_string.is_a?(String) ? tags_string.split(",").map(&:strip) : tags_string
    self.tags = tag_names.reject(&:blank?).map { |name| Tag.find_or_create_by(name: name.downcase) }
  end

  def tag_list
    tags.map(&:name).join(", ")
  end

  def ready?
    status == "ready"
  end

  def processing?
    status == "processing"
  end

  def failed?
    status == "failed"
  end

  def formatted_duration
    return nil unless duration_seconds

    minutes = duration_seconds / 60
    seconds = duration_seconds % 60
    format("%d:%02d", minutes, seconds)
  end

  private

  def generate_short_code
    return if short_code.present?

    loop do
      self.short_code = SecureRandom.alphanumeric(6)
      break unless Video.exists?(short_code: short_code)
    end
  end

  def original_presence
    errors.add(:original, "must be attached") unless original.attached?
  end

  def original_format
    return unless original.attached?

    unless ALLOWED_FORMATS.include?(original.content_type)
      errors.add(:original, "must be a video file (MP4, MOV, AVI, MPEG, WebM, M4V, MKV)")
    end
  end

  def original_size
    return unless original.attached?

    if original.blob.byte_size > MAX_SIZE
      errors.add(:original, "must be less than 500MB")
    end
  end
end
