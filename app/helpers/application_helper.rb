module ApplicationHelper
  def prohibited_message(error)
    I18n.t('common.error.message')
  end
end
