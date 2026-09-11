class ShippingCompaniesController < ApplicationController
  before_action :set_shipping_company, only: %i[show edit update destroy]
  before_action :sign_in_required

  # GET /shipping_companies
  # GET /shipping_companies.json
  def index
    @shipping_companies = ShippingCompany.my_shipping_companies(current_company).page(params[:page])
    #@shipping_companies = current_company.shipping_companies.page(params[:page])
  end

  # GET /shipping_companies/1
  # GET /shipping_companies/1.json
  def show() end

  # GET /shipping_companies/new
  def new
    @shipping_company = ShippingCompany.new
  end

  # GET /shipping_companies/1/edit
  def edit() end

  # POST /shipping_companies
  # POST /shipping_companies.json
  def create
    @shipping_company = ShippingCompany.new(shipping_company_params)
    @shipping_company.company = current_company

    respond_to do |format|
      if @shipping_company.save
        format.html { redirect_to edit_shipping_company_url(@shipping_company) , notice: 'shipping_company was successfully created.' }
        format.json { render :show, status: :created, location: @shipping_company }
      else
        format.html { render :new }
        format.json { render json: @shipping_company.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /shipping_companies/1
  # PATCH/PUT /shipping_companies/1.json
  def update
    respond_to do |format|
      if @shipping_company.update(shipping_company_params)
        format.html { redirect_to edit_shipping_company_url(@shipping_company), notice: 'shipping_company was successfully updated.' }
        format.json { render :show, status: :ok, location: @shipping_company }
      else
        format.html { render :edit }
        format.json { render json: @shipping_company.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /shipping_companies/1
  # DELETE /shipping_companies/1.json
  def destroy
    @shipping_company.destroy
    respond_to do |format|
      format.html { redirect_to shipping_companies_url, notice: 'shipping_company was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private

    # Use callbacks to share common setup or constraints between actions.
    def set_shipping_company
      @shipping_company = current_company.shipping_companies.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def shipping_company_params
      params.require(:shipping_company).permit(:shipping_company_name)
    end
end
