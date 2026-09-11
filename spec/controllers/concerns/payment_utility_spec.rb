require 'rails_helper'

RSpec.describe PaymentUtility, type: :controller do
  controller ApplicationController do
    include PaymentUtility
  end

  describe "make_items_array" do
    pending "converts params to array properly #{__FILE__}"
    #it "converts params to array properly" do
      #make_items_array()
    #end
  end
end
