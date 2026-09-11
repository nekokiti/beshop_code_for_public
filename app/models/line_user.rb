class LineUser < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
	has_one :cart
	has_many :orders
	has_one :payer
	has_one :address_phase
  has_many :gotten_products
  belongs_to :company

  scope :my_line_users, ->(current_company) { where(company_id: current_company) }

  attr_accessor :displayName

  def email_required?
    false
  end

  def email_changed?
    false
  end

  def is_address_set?
    self.address_set_flg
  end

  def self.create_line_user(line_id, company)
    LineUser.find_or_create_by!(line_id: line_id, company: company)
  end

  def make_address_options_for_paypal(address_override)
    return "" unless address_override.positive?

    address_options = {}
    address_options[:name] = self.last_name + self.first_name
    address_options[:zip] = self.zip
    address_options[:address1] = self.address_street
    address_options[:city] = self.address_city
    address_options[:state] = self.address_state
    address_options[:country] = "JP"
    address_options[:phone] = self.tel
    return address_options
  end

  def set_address_with_hash(address_hash)
    state = address_hash["results"].first["address1"]
    city = address_hash["results"].first["address2"]
    street = address_hash["results"].first["address3"]
    set_state(state)
    set_city(city)
    set_street_by_postal_code(street)
  end

  def set_address_set_flg
    update(address_set_flg: true)
  end

  def set_state(state)
    update(address_state: state)
  end

  def set_city(city)
    update(address_city: city)
  end

  def set_street(address_street)
    self.update(address_street: address_street)
  end

  def set_street_by_postal_code(address_street)
    self.update(address_street_by_postal_code: address_street)
  end

  def set_zip(zip)
    self.update(zip: zip)
  end

  def set_first_name(first_name)
    self.update(first_name: first_name)
  end

  def set_last_name(last_name)
    #こうするとログが出る。他も合わせるか、特にログを出さなければ外していい。
    begin
      self.update!(last_name: last_name)
    rescue => e
      logger.debug("#{e.message}")
    end
  end

  def set_email(email)
    self.update(email: email)
  end

  def set_tel(tel)
    self.update(tel: tel)
  end

  def set_room_number(room_number)
    self.update(room_number: room_number)
  end

  def social_profile(provider)
   social_profiles.select{ |sp| sp.provider == provider.to_s }.first
  end

  def set_values(omniauth)
    return if provider.to_s != omniauth['provider'].to_s || uid != omniauth['uid']
    credentials = omniauth['credentials']
    info = omniauth['info']

    access_token = credentials['refresh_token']
    access_secret = credentials['secret']
    credentials = credentials.to_json
    name = info['name']
    #self.set_values_by_raw_info(omniauth['extra']['raw_info'])
  end

  def set_values_by_raw_info(raw_info)
    self.raw_info = raw_info.to_json
    self.save!
  end

  def age_since_account_created
    (Date.current - Date.new(created_at.year, created_at.month, created_at.day)).to_i
  end

  def age_since_last_order_at_excluded_paidy
    return 0 if orders.excluded_paidy.blank?

    last_order = orders.excluded_paidy.last
    (Date.current - Date.new(last_order.created_at.year,
                             last_order.created_at.month,
                             last_order.created_at.day)).to_i
  end

  def paid_total_price_excluded_paidy
    res = 0
    orders.excluded_paidy.each { |order| res += order.total_price }
    res
  end

  def last_order_price_excluded_paidy
    orders.excluded_paidy.try(:last) ? orders.excluded_paidy.last.total_price : 0
  end

end
