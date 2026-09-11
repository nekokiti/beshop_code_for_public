class ProductsController < ApplicationController
  include CsvImport
  before_action :sign_in_required
  before_action :set_product, only: %i[show edit update destroy]

  # GET /products
  # GET /products.json
  def index
    @products = Product.my_products(current_company).page(params[:page])
  end

  # GET /products/1
  # GET /products/1.json
  def show() end

  # GET /products/new
  def new
    @product = Product.new
    @product.build_otorioki_time
    Size.count.times {@product.size_products.build}
  end

  # GET /products/1/edit
  def edit()
    (Size.count - @product.size_products.count).times {@product.size_products.build}
    @product.build_otorioki_time if @product.otorioki_time.nil?
  end

  # POST /products
  # POST /products.json
  def create
    @product = Product.new(product_params)
    @product.has_size = @product.reduction_tax = false if @product.coupon_flg
    @product.no_extra_fee = true if @product.coupon_flg
    @product.company = current_company
    respond_to do |format|
      if @product.save
        format.html { redirect_to @product, notice: 'Product was successfully created.' }
        format.json { render :show, status: :created, location: @product }
      else
        format.html { render :new }
        format.json { render json: @product.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /products/1
  # PATCH/PUT /products/1.json
  def update
    respond_to do |format|
      product_params_copy = product_params
      product_params_copy["has_size"] = product_params_copy["reduction_tax"] = false if product_params["coupon_flg"].to_i > 0
      if @product.update(product_params_copy)
        format.html { redirect_to @product, notice: 'Product was successfully updated.' }
        format.json { render :show, status: :ok, location: @product }
      else
        format.html { render :edit }
        format.json { render json: @product.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /products/1
  # DELETE /products/1.json
  def destroy
    @product.destroy
    respond_to do |format|
      format.html { redirect_to products_url, notice: 'Product was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def csv_export
    products = Product.my_products(current_company).page(params[:page])
    str_time = Time.zone.now.strftime("%Y%m%d%H%M%S")
    send_data ProductsCsvExportService.new(products).excute, type: 'text/csv; charset=shift_jis', filename: "products_#{str_time}.csv"
  end

  def csv_import
    file = params[:file]
    msgs = product_import(file)
    msgs = "csvの取り込みを開始しました。暫くしてからページをリロードして下さい" if msgs.nil?
    respond_to do |format|
      format.html { redirect_to products_url, danger: msgs}
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_product
    @product = current_company.products.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def product_params
    params.require(:product).permit(:name, :jancode,:description,
                                    :image_path, :url,
                                    :movie_path, :price,
                                    :recommend_flg, :coupon_flg, :no_extra_fee,
                                    :otorioki_flg, :quantity, :has_size,
                                    :reduction_tax, :disp_inventory_flg, :tax_free_flg,
                                    tag_ids: [], otorioki_time_attributes: [:id, :min_time],
                                    size_products_attributes: [[:quantity, :size_id, :id]]
                                   )
  end
end
