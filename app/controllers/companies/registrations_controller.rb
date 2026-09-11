class Companies::RegistrationsController < Devise::RegistrationsController
  before_action :basic_validation, only: [:new]
  # before_action :configure_sign_up_params, only: [:create]
  # before_action :configure_account_update_params, only: [:update]
  require "securerandom"
  # GET /resource/sign_up
  def new
    super
  end

  def build_resource(hash = nil)
    hash[:unique_id] = SecureRandom.uuid unless hash.nil?
    super
  end

  # POST /resource
  # def create
  #   super
  # end

  # GET /resource/edit
  def edit
    unless resource.channel_secret.nil?
      resource.channel_secret = resource.decrypt_channel_secret
    end
    super
  end

  # PUT /resource
  def update
    super
    return unless @company.errors.messages.blank?

    cs = params[:company][:channel_secret]
    @company.update!(channel_secret: resource.encrypt_channel_secret(cs))
  end

  # DELETE /resource
  # def destroy
  #   super
  # end

  # GET /resource/cancel
  # Forces the session data which is usually expired after sign
  # in to be expired now. This is useful if the user wants to
  # cancel oauth signing in/up in the middle of the process,
  # removing all OAuth session data.
  # def cancel
  #   super
  # end

  # protected

  # If you have extra params to permit, append them to the sanitizer.
  # def configure_sign_up_params
  #   devise_parameter_sanitizer.permit(:sign_up, keys: [:attribute])
  # end

  # If you have extra params to permit, append them to the sanitizer.
  # def configure_account_update_params
  #   devise_parameter_sanitizer.permit(:account_update, keys: [:attribute])
  # end

  # The path used after sign up.
  # def after_sign_up_path_for(resource)
  #   super(resource)
  # end

  # The path used after sign up for inactive accounts.
  # def after_inactive_sign_up_path_for(resource)
  #   super(resource)
  # end

  def basic_validation
    return unless Rails.env == "production"

    authenticate_or_request_with_http_basic do |name, password|
      name == ENV['BASIC_AUTH_NAME'] && password == ENV['BASIC_AUTH_PASSWORD']
    end
  end

  def after_update_path_for(resource)
    edit_company_registration_path(resource)
  end
end
