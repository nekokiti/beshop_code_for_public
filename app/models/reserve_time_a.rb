class ReserveTimeA < ApplicationRecord
  belongs_to :company_reserve

  validates :start_date, presence: true
  validates :end_date, presence: true
  validate :check_date
  validate :check_time

  def check_date
    if start_date and end_date
      errors[:date] << '開始日　＞　終了日' if start_date > end_date
      errors[:date] << '7日制限' if end_date - start_date > 7
    end
  end

  def check_time
    if ((from_time_2.nil? && end_time_2) || (from_time_2 && end_time_2.nil?)) || \
      ((from_time_1.nil? && end_time_1) || (from_time_1 && end_time_1.nil?))
      errors[:time2] << '一緒に入力してください'
    end

    if from_time_1 && end_time_1
      errors[:time1] << '開始時間　＞　終了時間' if from_time_1 > end_time_1
    end

    if from_time_2 && end_time_2
      errors[:time2] << '開始時間　＞　終了時間' if from_time_2 > end_time_2
    end
  end
end
