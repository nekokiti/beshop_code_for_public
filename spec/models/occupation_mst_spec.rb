require 'rails_helper'
RSpec.describe OccupationMst, type: :model do
  let(:company) { create(:company) }

  describe 'OccupationMst#is_hotel?' do
    it "returns true" do
      company.update!(occupation_mst_id: OccupationMst::HOTEL)
      expect(OccupationMst.is_hotel?(company: company)).to be_truthy
    end
  end
end
