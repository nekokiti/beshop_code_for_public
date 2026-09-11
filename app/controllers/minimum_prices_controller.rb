class MinimumPricesController < ApplicationController
  before_action :set_minimum_price, only: %i[new show edit update]
  before_action :sign_in_required

  # GET /minimum_price/1
  # GET /minimum_price/1.json
  def show() end

  # GET /minimum_price/new
  def new
    if @minimum_price.nil?
      @minimum_price = MinimumPrice.new
    else
      redirect_to edit_minimum_price_url(@minimum_price)
    end
  end

  # GET /minimum_price/1/edit
  def edit() end

  # POST /minimum_price
  # POST /minimum_price.json
  def create
    @minimum_price = MinimumPrice.new(minimum_price_params)
    @minimum_price.company = current_company

    respond_to do |format|
      if @minimum_price.save
        format.html { redirect_to edit_minimum_price_url(@minimum_price) , notice: 'minimum_price was successfully created.' }
        format.json { render :show, status: :created, location: @minimum_price }
      else
        format.html { render :new }
        format.json { render json: @minimum_price.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /minimum_price/1
  # PATCH/PUT /minimum_price/1.json
  def update
    respond_to do |format|
      if @minimum_price.update(minimum_price_params)
        format.html { redirect_to edit_minimum_price_url(@minimum_price), notice: 'minimum_price was successfully updated.' }
        format.json { render :show, status: :ok, location: @minimum_price }
      else
        format.html { render :edit }
        format.json { render json: @minimum_price.errors, status: :unprocessable_entity }
      end
    end
  end

  private

    # Use callbacks to share common setup or constraints between actions.
    def set_minimum_price
      @minimum_price = current_company.minimum_price
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def minimum_price_params
      params.require(:minimum_price).permit(:price)
    end
end
