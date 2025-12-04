# A lightweight session-like object for API token authentication
# Allows API requests to work with the same Current.session.user pattern
class VirtualSession
  attr_reader :user

  def initialize(user)
    @user = user
  end
end
