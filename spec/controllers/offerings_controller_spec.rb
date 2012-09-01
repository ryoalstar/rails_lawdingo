require "spec_helper"

describe OfferingsController do
  DatabaseCleaner.clean

  context "#edit" do
    render_views

    before :each do
      controller.stubs(:current_user).returns(james)
      controller.stubs(:authenticate).returns(james)
      Offering.expects(:find).with(offering.id.to_s).returns(offering)

      get :edit, id: offering.id
    end

    let :james do
      FactoryGirl.build_stubbed(:lawyer, first_name: "James")
    end

    let :offering do
      FactoryGirl.build_stubbed(:offering)
    end

    it "should response successfully" do
      response.code.should eq("200")
    end

    it "should render the offerings/edit template" do
      response.should render_template(:edit)
      response.body.should =~ /Edit a fixed-price offer/
    end
  end
end
