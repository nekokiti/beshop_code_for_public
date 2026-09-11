class Payments::CommonController < ApplicationController
  include OrderConfirmMail
  def complete# {{{
    send_confirm_mail(hash: params[:cart_hash], skip_email: params[:skip_email])
    #redirect_to 'line://ti/p/@kli0001p'
    redirect_to action: 'order_detail', cart_hash: params[:cart_hash]
  end# }}}

  def order_detail# {{{
    @order = Cart.get_cart_by_hash_with_deleted(params[:cart_hash]).order
    render :layout => 'public'
  end# }}}

  def inventory_error# {{{
    cart = Cart.get_cart_by_hash(params[:cart_hash])
    @out_of_inventory = Cart.out_of_inventory(cart)
  end# }}}

end
