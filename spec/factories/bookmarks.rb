FactoryBot.define do
  factory :bookmark do
    user
    sequence(:title) { |n| "Bookmark #{n}" }
    sequence(:url) { |n| "https://example#{n}.com" }
    description { "A sample bookmark" }
    is_public { false }
  end
end
