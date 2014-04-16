module RouteHawk
  module RolesHelper

    # ROUTES
    def authorize_route!
      if $SKIP_AUTHORIZATION || authorized_route?(current_route)
        logger.info "***AUTH*** Access Permitted to: #{current_route.defaults}" if $DEBUG_AUTH
      else
        logger.info "***AUTH*** Access Denied to: #{current_route.defaults}" if $DEBUG_AUTH
        access_denied!
      end
    end

    # PATHS
    def permit_path?(path, method=nil)
      return true if $SKIP_AUTHORIZATION || current_admin?
      authorized_route? route_for_path(path, method)
    end

    # each path can be a string or a {:path_info => '/roles', :method => 'GET'}
    def permit_any_path?(*paths)
      # NOooo...: return true if paths.empty?
      return true if $SKIP_AUTHORIZATION || current_admin?
      paths.any? {|p| p.is_a?(Hash) ? permit_path?(p[:path], p[:method]) : permit_path?(p)}
    end

    # ADMINS
    # use this if you want to ensure only admins can access an action
    def must_be_admin!
      access_denied! unless current_admin?
    end

    def current_admin?
      current_person.try(:is_admin?)
    end

    # ANON
    def anon_permit_route?(route)
      # make sure we only load this once per request
      @anon_role ||= Role.anon_role
      @anon_role.permit_route?(route)
    end

    # == MENU HELPERS (HTML)
    # a link hash is [{:name => n, :path => p, :sublist => [link_hash, link_hash]}, {..}]
    def menu_list_if_permitted(*link_hashes)
      paths = link_hashes.compact.collect{|lh| lh[:path]}
      menu_list(*link_hashes) if permit_any_path?(*paths)
    end

    # renders a ul, li style list, recursively
    def menu_list(*link_hashes)
      content_tag :ul do 
        links = link_hashes.collect do |lh| 
          menu_item_if_permitted(lh[:name], lh[:path], *lh[:sublist])
        end
        raw links.join
      end
    end

    def menu_item_if_permitted(name, path, *link_hashes)
      paths = ([path] + link_hashes.compact.collect{|lh| lh[:path]}).compact
      menu_item(name, path, *link_hashes) if permit_any_path?(*paths)
    end

    # renders a li item, recursively
    def menu_item(name, path, *link_hashes)
      content_tag :li do
        link = link_to(name, path) if permit_path?(path)
        sub = menu_list_if_permitted(*link_hashes) unless link_hashes.empty?
        link.to_s + sub.to_s
      end
    end

    protected
    def authorized_route?(route)
      # 1. is an admin
      # 2. is permitted by anonymous role
      # 3. is permitted by user's roles
      current_admin? || anon_permit_route?(route) || current_person.try(:permit_route?, route)
    end

    def current_route
      route, match, params = Rails.application.routes.set.recognize(request)
      return route
    end

    # NOTE: returns a Rack::Mount::Route, not an ActionDispatch route! 
    # convert a path into a route which we can check auth for
    def route_for_path(path, method=nil)
      env = Rack::MockRequest.env_for(path || "", {:method => method})
      req = ActionDispatch::Request.new(env)
      route, matches, params = Rails.application.routes.set.recognize(req)
      return route
    end

    def debug_route
      route, match, params = Rails.application.routes.set.recognize(request)
      #logger.info "***ROUTING*** recognize_path: #{Rails.application.routes.recognize_path request.path}"
      #logger.info "***ROUTING*** Route: #{route}"
      logger.info "***ROUTING*** route.name: #{route.name}"
      logger.info "***ROUTING*** route.defaults: #{route.defaults}"
      logger.info "***ROUTING*** route.conditions (path_info, request_method): #{route.conditions[:path_info].to_s}, #{route.conditions[:request_method].to_s}"
    end

  end
end
