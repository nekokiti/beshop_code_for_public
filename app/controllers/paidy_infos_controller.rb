class PaidyInfosController < ApplicationController
  before_action :sign_in_required
  before_action :set_paidy_info, only: %i[new show edit update destroy]

  def new()
    if @paidy_info.nil?
      @paidy_info = PaidyInfo.new
    else
      redirect_to edit_paidy_info_url(@paidy_info)
    end
  end

  def show() end

  def edit
    @paidy_info.decrypt_keys
  end


  def create
    @paidy_info = PaidyInfo.new(paidy_info_params)
    @paidy_info.company = current_company

    respond_to do |format|
      if @paidy_info.save_with_encrypt
        format.html { redirect_to edit_paidy_info_url(@paidy_info), notice: 'PaidyInfo was successfully created.' }
        format.json { render :show, status: :created, location: @paidy_info }
      else
        format.html { render :new }
        format.json { render json: @paidy_info.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @paidy_info.update_with_encrypt(paidy_info_params)
        format.html { redirect_to edit_paidy_info_url(@paidy_info), notice: 'PaidyInfo was successfully updated.' }
        format.json { render :show, status: :ok, location: @paidy_info }
      else
        format.html { render :edit }
        format.json { render json: @paidy_info.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @paidy_info.destroy
    respond_to do |format|
      format.html { redirect_to paidy_info_url, notice: 'PaidyInfo was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_paidy_info
    @paidy_info = PaidyInfo.my_paidy_info(current_company)
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def paidy_info_params
    params.require(:paidy_info).permit(:public_key, :secret_key, :enable_flg)
  end

end
