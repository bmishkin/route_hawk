FactoryGirl.define do

  factory :role, :class => RouteHawk::Role do
    sequence(:name) {|n| "role_#{n}"}
  end

  factory :role_route, :class => RouteHawk::RoleRoute do
    role
  end
  
  
end
