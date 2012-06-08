require 'spec_helper'

describe ErrorsController do

  describe "GET 'error_404'" do
    it "returns http success" do
      get 'error_404'
      response.should be_success
    end
  end

end
