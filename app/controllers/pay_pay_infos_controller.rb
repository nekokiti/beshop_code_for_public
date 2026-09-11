class PayPayInfosController < ApplicationController
  before_action :sign_in_required
  before_action :set_pay_pay_info, only: %i[new show edit update destroy]

  def new()
    if @pay_pay_info.nil?
      @pay_pay_info = PayPayInfo.new
    else
      redirect_to edit_pay_pay_info_url(@pay_pay_info)
    end
  end

  def show() end

  def edit
    @pay_pay_info.decrypt_keys
  end


  def create
    @pay_pay_info = PayPayInfo.new(pay_pay_info_params)
    @pay_pay_info.company = current_company

    respond_to do |format|
      if @pay_pay_info.save_with_encrypt
        format.html { redirect_to edit_pay_pay_info_url(@pay_pay_info), notice: 'PayPayInfo was successfully created.' }
        format.json { render :show, status: :created, location: @pay_pay_info }
      else
        format.html { render :new }
        format.json { render json: @pay_pay_info.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @pay_pay_info.update_with_encrypt(pay_pay_info_params)
        format.html { redirect_to edit_pay_pay_info_url(@pay_pay_info), notice: 'PayPayInfo was successfully updated.' }
        format.json { render :show, status: :ok, location: @pay_pay_info }
      else
        format.html { render :edit }
        format.json { render json: @pay_pay_info.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @pay_pay_info.destroy
    respond_to do |format|
      format.html { redirect_to pay_pay_info_url, notice: 'PayPayInfo was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_pay_pay_info
    @pay_pay_info = PayPayInfo.my_pay_pay_info(current_company)
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def pay_pay_info_params
    params.require(:pay_pay_info).permit(:client_id, :client_secret, :merchant_id, :enable_flg)
  end

end
