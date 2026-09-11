class LineAuthInfosController < ApplicationController
  before_action :sign_in_required
  before_action :set_line_auth_info, only: %i[new show edit update destroy]

  def new()
    if @line_auth_info.nil?
      @line_auth_info = LineAuthInfo.new
    else
      redirect_to edit_line_auth_info_url(@line_auth_info)
    end
  end

  def show() end

  def edit
    @line_auth_info.decrypt_keys
  end


  def create
    @line_auth_info = LineAuthInfo.new(line_auth_info_params)
    @line_auth_info.company = current_company

    respond_to do |format|
      if @line_auth_info.save_with_encrypt
        format.html { redirect_to edit_line_auth_info_url(@line_auth_info), notice: 'LineAuthInfo was successfully created.' }
        format.json { render :show, status: :created, location: @line_auth_info }
      else
        format.html { render :new }
        format.json { render json: @line_auth_info.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @line_auth_info.update_with_encrypt(line_auth_info_params)
        format.html { redirect_to edit_line_auth_info_url(@line_auth_info), notice: 'LineAuthInfo was successfully updated.' }
        format.json { render :show, status: :ok, location: @line_auth_info }
      else
        format.html { render :edit }
        format.json { render json: @line_auth_info.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @line_auth_info.destroy
    respond_to do |format|
      format.html { redirect_to line_auth_info_url, notice: 'LineAuthInfo was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_line_auth_info
    @line_auth_info = LineAuthInfo.my_line_auth_info(current_company)
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def line_auth_info_params
    params.require(:line_auth_info).permit(:channel_id, :channel_secret)
  end

end
