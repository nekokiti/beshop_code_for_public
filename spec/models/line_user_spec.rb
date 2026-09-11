require 'rails_helper'

RSpec.describe LineUser, :type => :model do
  let(:user) { create(:line_user) }
  let(:company) { create(:company) }
  it "updates address with hash" do
    address_hash = {
      "message"=>nil,
      "results"=>[{
          "address1"=>"東京都",
          "address2"=>"豊島区",
          "address3"=>"目白",
          "kana1"=>"ﾄｳｷｮｳﾄ",
          "kana2"=>"ﾄｼﾏｸ",
          "kana3"=>"ﾒｼﾞﾛ",
          "prefcode"=>"13",
          "zipcode"=>"1710031"
        }],
      "status"=>200
    }

    user.set_address_with_hash(address_hash)
    state = address_hash["results"].first["address1"]
    city = address_hash["results"].first["address2"]
    street = address_hash["results"].first["address3"]
    expect(user.address_state).to eq state
    expect(user.address_city).to eq city
    expect(user.address_street_by_postal_code).to eq street
  end

  describe 'creating or getting line user' do
    context 'user does not exists' do
      it "create_line_user" do
        new_user = LineUser.create_line_user("sample_id", company)
        expect(new_user.line_id).to eq "sample_id"
      end
    end
    context 'user have already existed' do
      it "find_line_user" do
        found_user = LineUser.create_line_user(user.line_id, company)
        expect(found_user.line_id).to eq user.line_id
      end
    end
  end
  it "updates first_name" do
    first_name = "ファーストネーム"
    user.set_first_name(first_name)
    user.reload
    expect(user.reload.first_name).to eq first_name
  end
  it "updates last_name" do
    last_name = "ラストネーム"
    user.set_last_name(last_name)
    user.reload
    expect(user.reload.last_name).to eq last_name
  end
  it "updates zip" do
    zip_code = "1710031"
    user.set_zip(zip_code)
    user.reload
    expect(user.reload.zip).to eq zip_code
  end

  describe "set address" do
    context "use app paddress" do
      it "creates address options for paypal" do
        res = user.make_address_options_for_paypal(1)
        expect(res[:name]).to eq user.last_name + user.first_name
        expect(res[:address1]).to eq user.address_street
        expect(res[:city]).to eq user.address_city
        expect(res[:state]).to eq user.address_state
      end
    end
    context "use paypal address" do
      it "doesn not create address options for paypal" do
        res = user.make_address_options_for_paypal(0)
        expect(res).to eq ""
      end
    end
  end

  describe "age_since_account_created" do
    it "returns age since account created at" do
      user.update!(created_at: Time.current.ago(3.days))
      expect(user.age_since_account_created).to eq 3
    end
  end

  describe "paid_total_price_excluded_paidy" do
    it "returns total price of all orders" do
      Order.create!(line_user: user, total_price: 1000, payment_method: Order::PAYPAY)
      Order.create!(line_user: user, total_price: 2000, payment_method: Order::LINE_PAY)
      Order.create!(line_user: user, total_price: 3000, payment_method: Order::PAYPAL)
      Order.create!(line_user: user, total_price: 3000, payment_method: Order::PAIDY)
      expect(user.paid_total_price_excluded_paidy).to eq 6000
    end
  end

  describe "last_order_price_excluded_paidy" do
    context "has any orders" do
      it "returns price of last order" do
        Order.create!(line_user: user, total_price: 1000, payment_method: Order::PAYPAY)
        Order.create!(line_user: user, total_price: 2000, payment_method: Order::LINE_PAY)
        Order.create!(line_user: user, total_price: 3000, payment_method: Order::PAIDY)
        expect(user.last_order_price_excluded_paidy).to eq 2000
      end
    end
    context "has no orders" do
      it "returns 0" do
        expect(user.last_order_price_excluded_paidy).to eq 0
      end
    end
  end

  describe "age_since_last_order_at_excluded_paidy" do
    context "has any orders" do
      it "returns a day since last order" do
        Order.create!(line_user: user, total_price: 1000, created_at: Time.current.ago(7.days), payment_method: Order::PAYPAY)
        Order.create!(line_user: user, total_price: 2000, created_at: Time.current.ago(5.days), payment_method: Order::LINE_PAY)
        Order.create!(line_user: user, total_price: 3000, created_at: Time.current.ago(3.days), payment_method: Order::PAYPAL)
        Order.create!(line_user: user, total_price: 3000, created_at: Time.current.ago(1.days), payment_method: Order::PAIDY)
        expect(user.age_since_last_order_at_excluded_paidy).to eq 3
      end
    end
    context "has no orders" do
      it "returns 0" do
        expect(user.age_since_last_order_at_excluded_paidy).to eq 0
      end
    end
  end
end
