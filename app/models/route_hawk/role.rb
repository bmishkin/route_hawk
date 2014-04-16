module RouteHawk
  class Role < ActiveRecord::Base

    # special roles
    ANON_ROLE_NAME = 'anonymous'  # granted to not-logged-in sessinos
    DEFAULT_ROLE_NAME = 'basic'   # added to all users on creation
    SPECIAL_ROLE_NAMES = [ANON_ROLE_NAME, DEFAULT_ROLE_NAME]

    #== ASSOCIATIONS
    has_and_belongs_to_many :users, :class_name => RouteHawk.user_class, :uniq => true
    has_many :role_routes, :autosave => true

    validates :name, :presence => true, :uniqueness => true, :length => { :maximum => 255 }  

    # == SCOPES
    scope :by_name, order('name ASC')
    scope :with_role_routes, includes(:role_routes)

    # == CALLBACKS
    before_destroy :keep_special_roles
    protected
    def keep_special_roles
      !is_special_role?
    end

    # == INSTANCE FUNCTIONS
    public
    def to_s
      name
    end

    def is_special_role?
      SPECIAL_ROLE_NAMES.include?(name) 
    end

    # array of ActionDispatch::Routing::Route objs
    # only used for tests, for now
    def routes
      role_routes.collect {|rr| rr.route}
    end

    # a set of hashes [{:path_info => .., :request_method => ...}, {:path_info => .., :request_method => ..}]
    # used for searching - optimize later
    def routes_hash_set
      @hashed_routes ||= role_routes.collect {|rr| rr.to_hash }.to_set
    end

    # route_params = {"0"=>"true", "1"=>"true", "3"=>"true"}}
    def update_routes_from_params(route_params)
      route_params ||= [] # in case it is nil
      new_routes = []

      # add all of the routes specified, based on the index
      route_params.each do |key, val|
         add_route(new_route = Role.available_routes_sorted[key.to_i])
         new_routes << new_route
      end

      # check the existing routes, destroy any that are not in the new routes
      # note this will clean up any new routes that do not exist
      role_routes.each do |rr|
        rr.mark_for_destruction unless new_routes.include?(rr.route)
      end
    end

    #TBD: would like to att rr.route= to role_route and just assign the route
    def add_route(route)
      path_info, request_method = route.conditions[:path_info].to_s, route.conditions[:request_method].to_s
      self.role_routes.build(:path_info => path_info, :request_method => request_method) unless routes.include?(route) 
      # could use 'unless permit_route?(route)' instead, but fails tests because of instance var
    end

    def permit_route?(route)
      path_info, request_method = route.conditions[:path_info].to_s, route.conditions[:request_method].to_s
      routes_hash_set.include?({:path_info => path_info, :request_method => request_method})
    end

    # == CLASS FUNCTIONS
    # returns an array of ActionDispatch::Routing::Route's
    def Role.available_routes
      @@available_routes ||= Rails.application.routes.routes.to_a.uniq(&:to_s) # automagically remove any duplicate routes
    end

    def Role.available_routes_sorted
      Role.available_routes.sort_by! {|r| (r.defaults[:controller] || '') + (r.defaults[:action] || '')}
    end

    def Role.anon_role
      Role.find_by_name(ANON_ROLE_NAME)
    end

    def Role.all_but_anon
      Role.by_name.all - [Role.anon_role]
    end

    # used in migrations, to find routes based on action / controller
    # note this may not be unique (multiple routes can point to same action/controller)
    # returns a ActionDispatch::Routing::Route (or nil)
    # don't use this in everyday logic!!!!
    def Role.find_route_for(controller, action, verb=nil)
      Role.available_routes.find{|r| r.defaults[:controller] == controller && r.defaults[:action] == action && (!verb || r.verb == verb)}
    end

    # only used for tests
    def Role.reset_anon
      @@a_role = nil
    end

  end
end
