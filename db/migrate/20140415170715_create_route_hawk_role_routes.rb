class CreateRouteHawkRoleRoutes < ActiveRecord::Migration
  def change
    create_table :route_hawk_role_routes do |t|
      t.integer :role_id
      t.text :path_info
      t.string :request_method, :limit => 32
      t.timestamps
    end
  end
end
