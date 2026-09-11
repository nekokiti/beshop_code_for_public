class ShippingsController < ApplicationController
  before_action :sign_in_required
  before_action :set_shipping, only: %i[new show edit update destroy]

  def new() 
    if @shipping.nil?
      @shipping = Shipping.new
    else
      redirect_to edit_shipping_url(@shipping)
    end
  end

  def show() end

  def edit() end

  def create
    @shipping = Shipping.new(shipping_params)
    @shipping.company = current_company
    respond_to do |format|
      if @shipping.save
        format.html { redirect_to edit_shipping_url(@shipping), notice: 'Shipping was successfully created.' }
        format.json { render :show, status: :created, location: @shipping }
      else
        format.html { render :new }
        format.json { render json: @shipping.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @shipping.update(shipping_params)
        format.html { redirect_to edit_shipping_url(@shipping), notice: 'Shipping was successfully updated.' }
        format.json { render :show, status: :ok, location: @shipping }
      else
        format.html { render :edit }
        format.json { render json: @shipping.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @shipping.destroy
    respond_to do |format|
      format.html { redirect_to shipping_url, notice: 'Shipping was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_shipping
    @shipping = Shipping.my_shipping_info(current_company)
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def shipping_params
    params.require(:shipping).permit(:shipping_fee, :extra_fee)
  end
end
