class BookmarkletController < ApplicationController
  allow_unauthenticated_access

  def index
    @bookmarklet_url = new_bookmark_url
  end
end
