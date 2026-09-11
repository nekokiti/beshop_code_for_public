class LineUsersController < ApplicationController
  before_action :set_line_user, only: %i[show]
  before_action :set_line_client, only: %i[index show push]
  before_action :sign_in_required

  def index
    @line_users = LineUser.my_line_users(current_company).page(params[:page])
    @line_users.each_with_index do |line_user, index|
      @line_users[index].displayName =
        @client.get_user_profile(line_user.line_id).body["displayName"]
    end
    @line_users
  end

  def show
    @res = @client.get_user_profile(@line_user.line_id)
    @push_with_product_form = Form::PushWithProductForm.new
  end

  def push
    posts = Form::PushWithProductForm.new(push_with_product_form_params)
    @line_user = current_company.line_users.find(posts.id)
    utility = WebhookUtility.new
    res = @client.push(
      @line_user.line_id,
      utility.products_flex_template_with_chat_mode(
        Product.my_products(current_company).where(id: posts.product_ids),
        @line_user.line_id
      )
    )
    Rails.logger.debug("#{res.inspect}")
    redirect_to action: 'show', id: @line_user.id
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_line_user
    @line_user = current_company.line_users.find(params[:id])
  end

  def set_line_client
    @client = LineClient.new(current_company.channel_access_token)
  end

  def push_with_product_form_params
    params.require(:form_push_with_product_form).permit(:id, product_ids: [])
  end

end
