class OrdersController < ApplicationController
  before_action :sign_in_required
  before_action :set_order, only: %i[show edit update destroy]

  # GET /orders
  # GET /orders.json
  def index
    @order_find_form = Form::OrderFindForm.new
    @from = Time.zone.now.midnight
    @to = @from.end_of_day
    if params[:form_order_find_form].present?
      convert_date_from_date_selsect(params[:form_order_find_form])
      if params.has_key?(:csv)
        @orders = Form::OrderFindForm.search_order_with_products(
          current_company,
          @from,
          @to
        )
        strTime = Time.zone.now.strftime("%Y%m%d%H%M%S")
        send_data download_csv(@orders), type: 'text/csv; charset=shift_jis', filename: "order_#{strTime}.csv"
      else
        @orders = Form::OrderFindForm.search_order(
          current_company,
          @from,
          @to
        ).page(params[:page])
      end
    else
      @orders = Form::OrderFindForm.search_order(current_company,
                                                 @from, @to).page(params[:page])
    end
  end

  # GET /orders/1
  # GET /orders/1.json
  def show()
    client = LineClient.new(current_company.channel_access_token)
    @order.line_user.displayName =
      client.get_user_profile(@order.line_user.line_id).body["displayName"]
    @order.build_shipping_info if @order.shipping_info.nil?
  end

  # GET /orders/new
  def new
    @order = Order.new
  end

  # GET /orders/1/edit
  def edit() end

  # POST /orders
  # POST /orders.json
  def create
    @order = Order.new(order_params)

    respond_to do |format|
      if @order.save
        format.html { redirect_to @order, notice: 'Order was successfully created.' }
        format.json { render :show, status: :created, location: @order }
      else
        format.html { render :new }
        format.json { render json: @order.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /orders/1
  # PATCH/PUT /orders/1.json
  def update
    respond_to do |format|
      if @order.update(shipping_info_params)
        format.html { redirect_to @order, notice: '発送情報が更新されました。' }
        format.json { render :show, status: :ok, location: @product }
      else
        format.html { render :edit }
        format.json { render json: @order.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /orders/1
  # DELETE /orders/1.json
  def destroy
    @order.destroy
    respond_to do |format|
      format.html { redirect_to orders_url, notice: 'Order was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private

  def download_csv(orders)
    OrderCsvService.new(orders).excute
  end

  def convert_date_from_date_selsect(params_with_time)
    @from = Time.zone.local(
      params_with_time["created_at_from(1i)"].to_i,
      params_with_time["created_at_from(2i)"].to_i,
      params_with_time["created_at_from(3i)"].to_i
    )
    @to = Time.zone.local(
      params_with_time["created_at_to(1i)"].to_i,
      params_with_time["created_at_to(2i)"].to_i,
      params_with_time["created_at_to(3i)"].to_i,
      23,
      59,
      59
    )
  end

  # Use callbacks to share common setup or constraints between actions.
  def set_order
    @order = current_company.orders.find(params[:id])
  end

  def order_find_form_params
    params.require(:form_order_find_form).permit(Form::OrderFindForm::REGISTRABLE_ATTRIBUTES)
  end

  def shipping_info_params
    params.require(:order).permit(
      shipping_info_attributes: [:shipping_number, :shipping_day, :shipping_company_id],
    )
  end

end
