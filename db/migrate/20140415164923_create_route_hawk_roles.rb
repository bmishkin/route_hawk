class CreateRouteHawkRoles < ActiveRecord::Migration
  def change
    create_table :route_hawk_roles do |t|
      t.string :name
      t.timestamps
      t.index :name
    end
  end
end
