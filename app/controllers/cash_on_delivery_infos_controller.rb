class CashOnDeliveryInfosController < ApplicationController
  before_action :sign_in_required
  before_action :set_cash_on_delivery_info, only: %i[new show edit update destroy]

  def new()
    if @cash_on_delivery_info.nil?
      @cash_on_delivery_info = CashOnDeliveryInfo.new
    else
      redirect_to edit_cash_on_delivery_info_url(@cash_on_delivery_info)
    end
  end

  def show() end

  def edit() end

  def create
    @cash_on_delivery_info = CashOnDeliveryInfo.new(cash_on_delivery_info_params)
    @cash_on_delivery_info.company = current_company

    respond_to do |format|
      if @cash_on_delivery_info.save
        format.html { redirect_to edit_cash_on_delivery_info_url(@cash_on_delivery_info), notice: 'CashOnDeliveryInfo was successfully created.' }
        format.json { render :show, status: :created, location: @cash_on_delivery_info }
      else
        format.html { render :new }
        format.json { render json: @cash_on_delivery_info.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @cash_on_delivery_info.update(cash_on_delivery_info_params)
        format.html { redirect_to edit_cash_on_delivery_info_url(@cash_on_delivery_info), notice: 'CashOnDeliveryInfo was successfully updated.' }
        format.json { render :show, status: :ok, location: @cash_on_delivery_info }
      else
        format.html { render :edit }
        format.json { render json: @cash_on_delivery_info.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @cash_on_delivery_info.destroy
    respond_to do |format|
      format.html { redirect_to cash_on_delivery_info_url, notice: 'CashOnDeliveryInfo was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_cash_on_delivery_info
    @cash_on_delivery_info = current_company.cash_on_delivery_info
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def cash_on_delivery_info_params
    params.require(:cash_on_delivery_info).permit(:price, :enable_flg, :alternative_name)
  end

end
