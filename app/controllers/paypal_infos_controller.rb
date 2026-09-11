class PaypalInfosController < ApplicationController
  before_action :sign_in_required
  before_action :set_paypal_info, only: %i[new show edit update destroy]

  def new()
    if @paypal_info.nil?
      @paypal_info = PaypalInfo.new
    else
      redirect_to edit_paypal_info_url(@paypal_info)
    end
  end

  def show() end

  def edit
    @paypal_info.decrypt_keys
  end


  def create
    @paypal_info = PaypalInfo.new(paypal_info_params)
    @paypal_info.company = current_company

    respond_to do |format|
      if @paypal_info.save_with_encrypt
        format.html { redirect_to edit_paypal_info_url(@paypal_info), notice: 'PaypalInfo was successfully created.' }
        format.json { render :show, status: :created, location: @paypal_info }
      else
        format.html { render :new }
        format.json { render json: @paypal_info.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @paypal_info.update_with_encrypt(paypal_info_params)
        format.html { redirect_to edit_paypal_info_url(@paypal_info), notice: 'PayPalInfo was successfully updated.' }
        format.json { render :show, status: :ok, location: @paypal_info }
      else
        format.html { render :edit }
        format.json { render json: @paypal_info.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @paypal_info.destroy
    respond_to do |format|
      format.html { redirect_to paypal_info_url, notice: 'PaypalInfo was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_paypal_info
    @paypal_info = PaypalInfo.my_paypal_info(current_company)
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def paypal_info_params
    params.require(:paypal_info).permit(:paypal_credential_username, :paypal_credential_password,
                                        :email_id, :paypal_credential_signature, :enable_flg)
  end

end
