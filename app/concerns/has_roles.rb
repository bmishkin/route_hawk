module RouteHawk
  module IsConditionActivity
    extend ActiveSupport::Concern
    
    included do
      has_and_belongs_to_many :roles, :uniq => true
      has_many :role_routes, :through => :roles
    end
    
    public
    def grant_role!(role_name)
      r = Role.find_by_name(role_name.to_s)
      roles << r unless r.nil? || roles.include?(r)
    end

    def revoke_role!(role_name)
      r = Role.find_by_name(role_name.to_s)
      roles.delete(r) unless r.nil?
    end

    def has_role?(role_name)
      Role.where(name: role_name).count > 0
    end

    def unassigned_roles
      rs = Role.all_but_anon - self.roles
    end

    def is_admin?
      admin
    end

    def permit_route?(route)
      roles.with_role_routes.any? {|r| r.permit_route?(route)}
    end
  end
end
