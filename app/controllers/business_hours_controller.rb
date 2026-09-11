class BusinessHoursController < ApplicationController
  before_action :set_business_hour, only: %i[new show edit update]
  before_action :sign_in_required

  # GET /business_hour/1
  # GET /business_hour/1.json
  def show() end

  # GET /business_hour/new
  def new
    if @business_hour.nil?
      @business_hour = BusinessHour.new
    else
      redirect_to edit_business_hour_url(@business_hour)
    end
  end

  # GET /business_hour/1/edit
  def edit() end

  # POST /business_hour
  # POST /business_hour.json
  def create
    @business_hour = BusinessHour.new(business_hour_params)
    @business_hour.company = current_company

    respond_to do |format|
      if @business_hour.save
        format.html { redirect_to edit_business_hour_url(@business_hour) , notice: 'business_hour was successfully created.' }
        format.json { render :show, status: :created, location: @business_hour }
      else
        format.html { render :new }
        format.json { render json: @business_hour.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /business_hour/1
  # PATCH/PUT /business_hour/1.json
  def update
    respond_to do |format|
      if @business_hour.update(business_hour_params)
        format.html { redirect_to edit_business_hour_url(@business_hour), notice: 'business_hour was successfully updated.' }
        format.json { render :show, status: :ok, location: @business_hour }
      else
        format.html { render :edit }
        format.json { render json: @business_hour.errors, status: :unprocessable_entity }
      end
    end
  end

  private

    # Use callbacks to share common setup or constraints between actions.
    def set_business_hour
      @business_hour = current_company.business_hour
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def business_hour_params
      params.require(:business_hour).permit(:open_time, :close_time)
    end
end
