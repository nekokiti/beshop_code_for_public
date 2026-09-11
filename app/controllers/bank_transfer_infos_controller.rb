class BankTransferInfosController < ApplicationController
  before_action :sign_in_required
  before_action :set_bank_transfer_info, only: %i[new show edit update destroy]

  def new()
    if @bank_transfer_info.nil?
      @bank_transfer_info = BankTransferInfo.new
    else
      redirect_to edit_bank_transfer_info_url(@bank_transfer_info)
    end
  end

  def show() end

  def edit() end

  def create
    @bank_transfer_info = BankTransferInfo.new(bank_transfer_info_params)
    @bank_transfer_info.company = current_company

    respond_to do |format|
      if @bank_transfer_info.save
        format.html { redirect_to edit_bank_transfer_info_url(@bank_transfer_info), notice: 'BankTransferInfo was successfully created.' }
        format.json { render :show, status: :created, location: @bank_transfer_info }
      else
        format.html { render :new }
        format.json { render json: @bank_transfer_info.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @bank_transfer_info.update(bank_transfer_info_params)
        format.html { redirect_to edit_bank_transfer_info_url(@bank_transfer_info), notice: 'BankTransferInfo was successfully updated.' }
        format.json { render :show, status: :ok, location: @bank_transfer_info }
      else
        format.html { render :edit }
        format.json { render json: @bank_transfer_info.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @bank_transfer_info.destroy
    respond_to do |format|
      format.html { redirect_to bank_transfer_info_url, notice: 'BankTransferInfo was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_bank_transfer_info
    @bank_transfer_info = current_company.bank_transfer_info
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def bank_transfer_info_params
    params.require(:bank_transfer_info).permit(:enable_flg)
  end

end
