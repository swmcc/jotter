class User < ApplicationRecord
  has_secure_password
  has_many :sessions, dependent: :destroy
  has_many :api_tokens, dependent: :destroy
  has_many :bookmarks, dependent: :destroy
  has_many :galleries, dependent: :destroy
  has_many :albums, dependent: :destroy
  has_many :photos, dependent: :destroy
  has_many :videos, dependent: :destroy

  normalizes :email_address, with: ->(e) { e.strip.downcase }
end
