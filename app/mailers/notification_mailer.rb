class NotificationMailer < ApplicationMailer
  default from: "info@byte-road.com"
  add_template_helper(OrdersHelper)

  def send_confirm_to_user_test(company)
    @company = company
    mail(
      to: company.email,
      subject: I18n.t('mailer.company.test_title')
    )
  end

  def send_confirm_to_user(order)
    @user = order.line_user
    @order = order
    mail(
      to: @user.email,
      subject: I18n.t('mailer.user.title')
    )
  end

  def send_notification_to_company(order)
    @company = order.company
    @order = order
    mail(
      to: @company.email,
      subject: I18n.t('mailer.company.title')
    )
  end
end
