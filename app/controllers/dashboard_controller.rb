class DashboardController < ApplicationController
  def index
    @bookmarks_count = Current.session.user.bookmarks.count
    @galleries_count = Current.session.user.galleries.count
    @albums_count = Current.session.user.albums.count
    @photos_count = Current.session.user.photos.count
  end
end
