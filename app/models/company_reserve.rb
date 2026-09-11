class CompanyReserve < ApplicationRecord
  belongs_to :company

  has_many :reserve_time_as, dependent: :destroy
  has_one :reserve_time_b, dependent: :destroy

  accepts_nested_attributes_for :reserve_time_as,
    allow_destroy: true,
    reject_if: proc { |attr| attr['start_date'].blank? }
  accepts_nested_attributes_for :reserve_time_b,
    allow_destroy: true,
    reject_if: proc { |attr| attr['days_after_from'].blank? }

  validate :check_nil

  RESERVE_PETERN_A = 1
  RESERVE_PETERN_B = 2

  def check_nil
    if (reserve_time_as.size.zero? and enable_flg == RESERVE_PETERN_A) or (reserve_time_b.nil? and enable_flg == RESERVE_PETERN_B)
      errors[:date] << 'を設定してください。'
    end
  end
end
