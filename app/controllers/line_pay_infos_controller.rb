class LinePayInfosController < ApplicationController
  before_action :sign_in_required
  before_action :set_line_pay_info, only: %i[new show edit update destroy]

  def new()
    if @line_pay_info.nil?
      @line_pay_info = LinePayInfo.new
    else
      redirect_to edit_line_pay_info_url(@line_pay_info)
    end
  end

  def show() end

  def edit
    @line_pay_info.decrypt_keys
  end


  def create
    @line_pay_info = LinePayInfo.new(line_pay_info_params)
    @line_pay_info.company = current_company

    respond_to do |format|
      if @line_pay_info.save_with_encrypt
        format.html { redirect_to edit_line_pay_info_url(@line_pay_info), notice: 'LinePayInfo was successfully created.' }
        format.json { render :show, status: :created, location: @line_pay_info }
      else
        format.html { render :new }
        format.json { render json: @line_pay_info.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @line_pay_info.update_with_encrypt(line_pay_info_params)
        format.html { redirect_to edit_line_pay_info_url(@line_pay_info), notice: 'LinePayInfo was successfully updated.' }
        format.json { render :show, status: :ok, location: @line_pay_info }
      else
        format.html { render :edit }
        format.json { render json: @line_pay_info.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @line_pay_info.destroy
    respond_to do |format|
      format.html { redirect_to line_pay_info_url, notice: 'LinePayInfo was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_line_pay_info
    @line_pay_info = LinePayInfo.my_line_pay_info(current_company)
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def line_pay_info_params
    params.require(:line_pay_info).permit(:channel_id, :channel_secret, :enable_flg)
  end

end
