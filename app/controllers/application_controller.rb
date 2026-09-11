class ApplicationController < ActionController::Base
  add_flash_types :success, :info, :warning, :danger
  protect_from_forgery with: :exception
  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :set_host

  # 例外ハンドル
  if Rails.env.production?
    rescue_from Exception,                        with: :render_500
    rescue_from ActiveRecord::RecordNotFound,     with: :render_404
    rescue_from ActionController::RoutingError,   with: :render_404
  end

  def routing_error
    raise ActionController::RoutingError, params[:path]
  end

  def set_host
    Rails.application.routes.default_url_options[:host] = request.host_with_port
  end

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:company_name])
    devise_parameter_sanitizer.permit(:account_update, keys: [:company_name, :channel_access_token, :channel_secret, paypal_info_attributes: [:paypal_credential_username, :email_id, :paypal_credential_password, :paypal_credential_signature]])
  end

  def sign_in_required
    redirect_to new_company_session_url unless company_signed_in?
  end

  def render_404(exception = nil)
    if exception
      logger.info "Rendering 404 with exception: #{exception.message}"
    end
    render template: "errors/error_404", status: 404, layout: 'application'
  end

  def render_500(exception = nil)
    if exception
      logger.info "Rendering 500 with exception: #{exception.message}"
    end
    render template: "errors/error_500", status: 500, layout: 'application'
  end

end
