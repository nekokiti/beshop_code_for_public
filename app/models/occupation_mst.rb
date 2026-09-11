class OccupationMst < ApplicationRecord
  DEFAULT = 0
  HOTEL = 1
  RESERVE = 2

  class << self

    def is_hotel?(company: target_company)
      company.occupation_mst_id == HOTEL
    end

    def is_reserve?(company: target_company)
      company.occupation_mst_id == RESERVE
    end

  end
end
