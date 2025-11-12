class DashboardController < ApplicationController
  def index
    @bookmarks_count = Current.session.user.bookmarks.count
  end
end
