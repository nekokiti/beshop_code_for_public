class LpMailer < ApplicationMailer
  DEFAULT_ADDRESS = "info@byte-road.com".freeze
  default from: DEFAULT_ADDRESS

  def thanks_mail_from_lp(data)
    @data = data
    mail(
      to: data[:email],
      subject: I18n.t('mailer.lp_to_sender.title')
    )
  end

  def accept_mail_from_lp(data)
    @data = data
    mail(
      to: DEFAULT_ADDRESS,
      subject: I18n.t('mailer.lp_to_me.title')
    )
  end
end
