Rails.application.routes.draw do
  #devise_for :line_users
  #devise_for :companies
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  root 'products#index'
  get 'public/auth_finish' => 'public#auth_finish'
  resources :lp, only: [:index] do
    get :maintenance, on: :collection, as: :maintenance
    post :mail_send, on: :collection, as: :mail_send
  end
  resources :line_users, only: %i[index show]
  post 'push' => 'line_users#push', as: :line_user_push
  resources :products do
    get :csv_export, on: :collection, as: :csv_export
    post :csv_import, on: :collection, as: :csv_import
  end
  resources :tags do
    get :csv_export, on: :collection, as: :csv_export
    post :csv_import, on: :collection, as: :csv_import
  end
  resources :shipping_companies
  resources :user_keywords, only: :index
  resources :orders
  resources :payers
  resource :extra_message
  resource :shipping
  resource :paypal_info
  resource :cash_on_delivery_info
  resource :bank_transfer_info
  resource :line_pay_info
  resource :pay_pay_info
  resource :paidy_info
  resource :line_auth_info
  resource :business_hour
  resource :minimum_price
  resource :company_reserve, only: [:new, :create]
  post '/callback' => 'webhook#callback', as: :webhook_callback
  get '/extra_message/send_test_mail' => 'extra_messages#send_test_mail', as: :send_test_mail
  get '/omniauth_line/require/:company_id' => 'omniauth_callbacks#auth_require', as: :omniauth_line_require
  get '/omniauth_line/get_auth_code/:company_id' => 'omniauth_callbacks#get_auth_code', as: :omniauth_get_auth_code

  namespace :payments do
    get 'complete/:cart_hash/' => 'common#complete', as: :common_complete
    get 'order_detail/:cart_hash/' => 'common#order_detail', as: :common_order_detail
    get 'inventory_error/:cart_hash/' => 'common#inventory_error', as: :common_inventory_error
    scope :line do
      get 'reserve_by_one_to_one/:product_id/:line_id/:size_id' => 'line#reserve_by_one_to_one', as: :reserve_by_one_to_one
      get 'reserve/:cart_hash' => 'line#reserve', as: :line_reserve
      get 'confirm' => 'line#confirm', as: :line_confirm
    end
    scope :paypay do
      get 'reserve/:cart_hash' => 'paypay#reserve', as: :paypay_reserve
      get 'confirm/:merchantPaymentId' => 'paypay#confirm', as: :paypay_confirm
    end
    scope :paidy do
      get 'checkout/:cart_hash' => 'paidy#checkout', as: :paidy_checkout
      post 'webhook' => 'paidy#webhook', as: :paidy_webhook
      post 'callback_api' => 'paidy#callback_api', as: :paidy_callback_api
      post 'order_info' => 'paidy#order_info', as: :paidy_order_info
      #get 'reserve/:cart_hash' => 'paypay#reserve', as: :paypay_reserve
    end
    scope :paypal do
      get 'new/:cart_hash/:use_app_address' => 'paypal_express#new', as: :paypal_payment
      get 'cancel' => 'paypal_express#cancel', as: :paypal_cancel
      get 'purchase/:cart_hash/:use_app_address' => 'paypal_express#purchase', as: :paypal_purchase
      post 'notify' => 'paypal_express#ipn', as: :paypal_ipn
    end
  end

  devise_for :companies, controllers: {
    confirmations: 'companies/confirmations',
    passwords:     'companies/passwords',
    registrations: 'companies/registrations',
    sessions:      'companies/sessions',
  }

  if Rails.env.development?
    mount LetterOpenerWeb::Engine, at: "/letter_opener"
  end

  get '*not_found' => 'application#routing_error'
  post '*not_found' => 'application#routing_error'
end
