class CompanyReservesController < ApplicationController
  before_action :build_company_reserve, only: [:new]
  before_action :set_company_reserve

  def new
    build_reserve_times(0)
  end

  def create
    @company_reserve.nil? ? create_reserve : update_reserve
  end

  def create_reserve
    @company_reserve = CompanyReserve.new(reserve_company_params)

    if @company_reserve.save
      redirect_to new_company_reserve_path
    else
      build_reserve_times(@company_reserve.enable_flg)
      render :new
    end
  end

  def update_reserve
    enable_flg = params[:company_reserve][:enable_flg].to_i
    update_params = enable_flg == CompanyReserve::RESERVE_PETERN_A ? reserve_a_params : reserve_b_params

    if @company_reserve.update(update_params)
      redirect_to new_company_reserve_path
    else
      build_reserve_times(@company_reserve.enable_flg)
      render :new
    end
  end

  def build_reserve_times(enable_flg)
    @company_reserve.build_reserve_time_b if @company_reserve.reserve_time_b.nil?
    (3 - @company_reserve.reserve_time_as.size).times { @company_reserve.reserve_time_as.build }
  end

  def build_company_reserve
    current_company.build_company_reserve if current_company.company_reserve.nil?
  end

  def set_company_reserve
    @company_reserve = current_company.company_reserve
  end

  def reserve_company_params
    params.require(:company_reserve).permit(
      :enable_flg,
      reserve_time_as_attributes: [:id, :start_date, :end_date, :from_time_1, :end_time_1, :from_time_2, :end_time_2],
      reserve_time_b_attributes: [:id, :days_after_from, :days_after_to, :from_time_1, :end_time_1, :from_time_2, :end_time_2],
    ).merge(company_id: current_company.id)
  end

  def reserve_a_params
    params.require(:company_reserve).permit(
      :enable_flg,
      reserve_time_as_attributes: [:id, :start_date, :end_date, :from_time_1, :end_time_1, :from_time_2, :end_time_2, :_destroy],
    )
  end

  def reserve_b_params
    params.require(:company_reserve).permit(
      :enable_flg,
      reserve_time_b_attributes: [:id, :days_after_from, :days_after_to, :from_time_1, :end_time_1, :from_time_2, :end_time_2],
    )
  end
end
