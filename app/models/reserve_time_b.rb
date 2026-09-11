class ReserveTimeB < ApplicationRecord
  belongs_to :company_reserve

  validates :days_after_from, presence: true
  validates :days_after_to, presence: true
  validate :check_date
  validate :check_time

  def check_date
    if days_after_from and days_after_to
      #errors[:date] << '開始日　＞　終了日' && return if days_after_from > days_after_to
      errors[:date] << '開始日から10日' if days_after_from > 10
      errors[:date] << '間８日' if days_after_to > 8
    end
  end

  def check_time
    if ((from_time_2.nil? && end_time_2) || (from_time_2 && end_time_2.nil?)) || \
      ((from_time_1.nil? && end_time_1) || (from_time_1 && end_time_1.nil?))
      errors[:time2] << '一緒に入力してください'
    end

    if from_time_1 and end_time_1
      errors[:time1] << '開始時間　＞　終了時間' if from_time_1 > end_time_1
    end

    if from_time_2 && end_time_2
      errors[:time2] << '開始時間　＞　終了時間' if from_time_2 > end_time_2
    end
  end
end
