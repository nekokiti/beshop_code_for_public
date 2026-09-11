class PayersController < ApplicationController
  before_action :set_payer, only: %i[show edit update destroy]
  before_action :sign_in_required

  def index
    @payers = Payer.page(params[:page])
  end

  def show
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_payer
    @payer = Payer.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def payer_params
    params.fetch(:order, {})
  end
end
