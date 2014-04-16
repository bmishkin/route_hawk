# == Schema Information
#
# Table name: roles
#
#  id         :integer         not null, primary key
#  name       :string(255)     not null
#  created_at :datetime
#  updated_at :datetime
#

require 'spec_helper'

module RouteHawk
  describe Role do

    # == ATTRIBUTES
    describe 'attributes' do
    end

    # == ASSOCATIONS
    describe 'associations' do
      # somehow breaking in rspec / shoulda: it {should have_and_belong_to_many(:people) }
      it {should have_many(:role_routes) }
    end

    # == VALIDATIONS
    describe 'validations' do
      it {should validate_presence_of(:name)}
      it {role = FactoryGirl.create(:role)
          role.should validate_uniqueness_of(:name) }
    end

    describe 'instance methods' do
      it "should not allow multiple roles of the same name" do
        a = FactoryGirl.create(:role)
        a.name = 'samerole'
        a.save
        b = FactoryGirl.create(:role)
        b.name = 'samerole'
        b.should_not be_valid
      end

      it "should not be able to destroy a special role" do
        a = Role.first_or_create(:name => Role::ANON_ROLE_NAME)
        a.destroy.should be_false
        a.destroyed?.should be_false
      end
    
      it "routes should work" do
        a = FactoryGirl.create(:role)
        a.routes.should be_empty
        a.role_routes << FactoryGirl.create(:role_route, :role => a)
        a.routes.first.class.should == ActionDispatch::Routing::Route
      end

      it "routes_hash_set should work" do
        a = FactoryGirl.create(:role)
        r = Role.available_routes.random
      
        a.role_routes.build(:path_info => b=r.conditions[:path_info].to_s, :request_method => c=r.conditions[:request_method].to_s)
        a.save!
      
        a.routes_hash_set.should include({:path_info => b, :request_method => c})
      end
    
      it "update_routes_from_params should add and delete routes" do
        a = FactoryGirl.create(:role) # should be empty

        p = {"1" => true, "7" => true, "29" => true}
        a.update_routes_from_params(p)
        a.save!
        a.routes.should include(*Role.available_routes.values_at(1,7,29))

        p = {"1" => true, "9" => true, "22" => true}
        a.update_routes_from_params(p)
        a.save!
        a.reload
        a.routes.should include(*Role.available_routes.values_at(1,9,22))
        a.routes.should_not include(*Role.available_routes.values_at(7,29))
      end
    
      it "add_route should work" do
        a = FactoryGirl.create(:role) # should be empty
        r = Role.available_routes.rand

        a.add_route(r)
        a.save!
        a.routes.should include(r)
        a.routes.length.should == 1

        a.add_route(r)
        a.save!
        a.routes.length.should == 1
      end
    
      it "permit_route? should work" do
        a = FactoryGirl.create(:role) # should be empty
        r = Role.available_routes.rand
        a.permit_route?(r).should be_false
        a.add_route(r)
        a.save!
        b = Role.find_by_id a.id # need to reload because of caching
        b.permit_route?(r).should be_true
      end
    end


    describe "class methods" do
      it "Role.available_routes should work" do
        Role.available_routes.should be_a(Array)
      end
    
      it "Role.anon_role should work if exists" do
        Role.reset_anon
        a = Role.first_or_create(:name => Role::ANON_ROLE_NAME)
        Role.anon_role.should == a
      end
    
      it "Role.all_but_anon should work" do
        Role.reset_anon
        rz = Role.all_but_anon
        k=FactoryGirl.create(:role, :name => Role::ANON_ROLE_NAME)
        Role.all_but_anon.should == rz
      end
    
      it "Role.find_route_for should work" do
        Role.reset_anon
        r = Role.available_routes.rand
        controller = r.defaults[:controller]
        action = r.defaults[:action]
        verb = r.verb
        Role.find_route_for(controller, action, verb).should_not be_nil
      end
    
      it "there should not be duplicate routes" do
         a = Rails.application.routes.routes
         b = a.uniq(&:to_s)
         a.should eq(b)
      end
    end
  end
end

    # 
    # it "should not allow role to be destroyed if assigned" do
    #   r = FactoryGirl.create(:role, :name => 'bar')
    #   r.destroy
    #   r.destroyed?.should be_true
    # end