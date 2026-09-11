class Sticon < ApplicationRecord
	belongs_to :sticonpackage
	has_many :sticon_products
	has_many :products, through: :sticon_products

  CART_A = '693255'
  CART_B = '693256'
  RECEIPT = '693265'
  CREDIT_A = '219952'
  CREDIT_B = '219953'

  def img_path 
		"#{sticonpackage.sticoncategory.name}/sticon#{id}.jpg"
	end

  #select * from sticons LEFT OUTER JOIN sticonpackages ON sticons.sticonpackage_id = sticonpackages.id where sticonpackages.package_id = '2000017' and sticons.sticon_id = '693279';
	def self.get_sticon_with_package(sticon_id, package_id)
		Sticon.eager_load(:sticonpackage).where("sticons.sticon_id = ? and sticonpackages.package_id = ?", sticon_id, package_id).first()
	end

end
