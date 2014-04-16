# == Schema Information
#
# Table name: role_routes
#
#  id             :integer         not null, primary key
#  role_id        :integer         not null
#  path_info      :text            not null
#  request_method :string(32)
#

require 'spec_helper'

describe RouteHawk::RoleRoute do

  # == ATTRIBUTES
  describe 'attributes' do
  end

  # == ASSOCATIONS
  describe 'associations' do
    it {should belong_to(:role) }
  end

  # == VALIDATIONS
  describe 'validations' do
    it {should validate_presence_of(:path_info)}
    # it {should validate_presence_of(:role_id)}
  end

  describe 'instance methods' do
    before(:each) do
      role = Factory.create(:role)
      @route = Role.available_routes.rand
      role.add_route(@route)
      role.save!
      @role_route = role.role_routes.first
    end
    
    it "route should work" do
      @role_route.route.should == @route
    end

    it "controller should work" do
      @role_route.controller.should == @route.defaults[:controller]
    end

    it "action should work" do
      @role_route.action.should == @route.defaults[:action]
    end

    it "path should work" do
      @role_route.path.should == @route.path
    end

    it "verb should work" do
      @role_route.verb.should == @route.verb    
    end


  end

end

