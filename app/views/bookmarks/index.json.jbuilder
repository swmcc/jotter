json.array! @bookmarks do |bookmark|
  json.id bookmark.id
  json.title bookmark.title
  json.url bookmark.url
  json.description bookmark.description
  json.short_code bookmark.short_code
  json.is_public bookmark.is_public
  json.tags bookmark.tags.pluck(:name)
  json.created_at bookmark.created_at.iso8601
  json.updated_at bookmark.updated_at.iso8601
end
