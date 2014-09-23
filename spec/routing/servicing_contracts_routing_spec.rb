require "rails_helper"

RSpec.describe ServicingContractsController, :type => :routing do
  describe "routing" do

    it "routes to #index" do
      expect(:get => "/servicing_contracts").to route_to("servicing_contracts#index")
    end

    it "routes to #new" do
      expect(:get => "/servicing_contracts/new").to route_to("servicing_contracts#new")
    end

    it "routes to #show" do
      expect(:get => "/servicing_contracts/1").to route_to("servicing_contracts#show", :id => "1")
    end

    it "routes to #edit" do
      expect(:get => "/servicing_contracts/1/edit").to route_to("servicing_contracts#edit", :id => "1")
    end

    it "routes to #create" do
      expect(:post => "/servicing_contracts").to route_to("servicing_contracts#create")
    end

    it "routes to #update" do
      expect(:put => "/servicing_contracts/1").to route_to("servicing_contracts#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/servicing_contracts/1").to route_to("servicing_contracts#destroy", :id => "1")
    end

  end
end
