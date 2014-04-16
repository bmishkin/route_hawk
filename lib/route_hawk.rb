require "route_hawk/engine"

module RouteHawk
  mattr_accessor :user_class

  # returns the class we're using, as a class object
  def self.user_class
    @@user_class ||= 'User'
    # @@user_class.constantize
  end
end
