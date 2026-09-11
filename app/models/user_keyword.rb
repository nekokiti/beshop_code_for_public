class UserKeyword < ApplicationRecord

  def self.setkeywords(keywords)
	  user_keywords = []
	  keywords.each do |k|
		  if UserKeyword.exists?(keyword: k)
				user_keyword = UserKeyword.where(keyword: k).first
				user_keyword.increment!(:counts)
		  else
	      user_keywords << UserKeyword.new(keyword: k)
			end
	  end
	  UserKeyword.import user_keywords
	end

end
