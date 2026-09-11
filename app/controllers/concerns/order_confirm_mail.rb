module OrderConfirmMail
  extend ActiveSupport::Concern
  def send_confirm_mail(hash:, skip_email: false)
    order = Cart.get_cart_by_hash_with_deleted(hash).order
    unless skip_email
      if CheckMail.check(email: order.line_user.email)
        NotificationMailer.send_confirm_to_user(order).deliver_later
      end
      NotificationMailer.send_notification_to_company(order).deliver_later
    end
    order
  end
end
