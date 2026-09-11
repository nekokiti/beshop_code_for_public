class Sticonpackage < ApplicationRecord
	has_many :sticons
	belongs_to :sticoncategory
  STUFF = '2000017'
  OTHERS = '2000010'
end
