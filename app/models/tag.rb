class Tag < ApplicationRecord
  has_many :taggings, dependent: :destroy
  has_many :bookmarks, through: :taggings, source: :taggable, source_type: "Bookmark"

  validates :name, presence: true, uniqueness: true

  before_validation :normalize_name

  private

  def normalize_name
    self.name = name.downcase.strip if name.present?
  end
end
