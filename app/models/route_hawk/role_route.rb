module RouteHawk
  class RoleRoute < ActiveRecord::Base

    belongs_to :role

    validates :path_info, :presence => true
    validates :request_method, :length => {:maximum => 32}
    #keeps role#create from working, db enforces anyway
    # validates :role_id, :presence => true
    validates :role_id, :uniqueness => {:scope => [:path_info, :request_method]}
    validates :route, :presence => true # must yield a valid route as defined below

    # == SCOPES

    # returns the ActionDispatch::Routing::Route for this role_route
    def route
      @route ||= Role.available_routes.find {|r| r.conditions[:path_info].to_s == path_info && r.conditions[:request_method].to_s == request_method}
    end

    def controller
      route ? route.defaults[:controller] : ""
    end

    def action
      route ? route.defaults[:action] : ""
    end

    def path
      route ? route.path : ""
    end

    def verb
      route ? route.verb : ""
    end

    def to_hash
      {:path_info => path_info, :request_method => request_method}
    end

  end
end
