module Yahooapi extend ActiveSupport::Concern
	require 'uri'
	require 'nokogiri'
	require 'open-uri'
	require 'active_record'
	require 'activerecord-import'
	def getKanji(sentence)
		#logger = Logger.new('log/development.log')
		app_id = "dj0zaiZpPWVpUGdSSkhyY1cyNSZzPWNvbnN1bWVyc2VjcmV0Jng9YTc-"
		url = "https://jlp.yahooapis.jp/JIMService/V1/conversion?appid=" + app_id + "&sentence=" + sentence

		xml = Nokogiri::XML(open(URI.escape(url)).read)
    xml.remove_namespaces!
		item_nodes = xml.xpath('//Candidate')
    res = Array.new()
		item_nodes.each do |item|
      res.push(item.text)
    end
    return res
=begin
		item_nodes = xml.xpath('//item')
		if item_nodes.length <= 0
			PageNum.first.update_attribute(:page_num, 1)
			current_num = PageNum.select(:page_num).first
			url = 'https://allcoupon.jp/api-v2/coupon?output=xml&category_type=%E3%82%B0%E3%83%AB%E3%83%A1&category_name=%E3%82%B0%E3%83%AB%E3%83%A1&limit=30' + '&page=' + current_num.page_num.to_s + '&apikey=' + apikey
			xml = Nokogiri::XML(open(url).read)
			item_nodes = xml.xpath('//item')
		end
		coupons = Array.new()
		item_nodes.each do |item|
			#groupon直売は除外
			unless (item.xpath('coupon_addr').text == '東京都渋谷区東1-2-20' \
			&& item.xpath('coupon_shop').text == 'gloshop' \
			&& item.xpath('coupon_shop').text == 'ブリランテ' \
			&& item.xpath('coupon_title').text.include?("バッグ") \
			&& item.xpath('coupon_title').text.include?("ネックレス") \
			&& item.xpath('coupon_title').text.include?("サプリ") \
			&& item.xpath('coupon_title').text.include?("教室") \
			&& item.xpath('coupon_title').text.include?("財布") \
			&& item.xpath('coupon_title').text.include?("メイク") \
			&& item.xpath('coupon_title').text.include?("部屋") \
			&& item.xpath('coupon_title').text.include?("タバコ") \
			&& item.xpath('coupon_title').text.include?("ペット") \
			&& item.xpath('coupon_title').text.include?("ベッド") \
			&& item.xpath('coupon_title').text.include?("シーツ") \
			&& item.xpath('coupon_title').text.include?("印鑑") \
			&& item.xpath('coupon_title').text.include?("トレーニング") \
			&& item.xpath('coupon_title').text.include?("クリーニング") \
			&& item.xpath('coupon_title').text.include?("ネイル")) then
				if(Coupon.exists?(original_id: item.xpath('coupon_id').text.to_i))
					coupon = Coupon.where(original_id: item.xpath('coupon_id').text.to_i).first
					coupon.update(
						#original_id: item.xpath('coupon_id').text.to_i,
						title: item.xpath('coupon_title').text,
						summary: item.xpath('coupon_summary').text,
						addr: item.xpath('coupon_addr').text,
						teika: item.xpath('coupon_teika').text.to_i,
						kakaku: item.xpath('coupon_kakaku').text.to_i,
						expired: item.xpath('coupon_untilldatetime').text,
						access: item.xpath('coupon_access').text,
						shop_name: item.xpath('coupon_shop').text,
						url: item.xpath('coupon_original_url').text,
				  	photo_url: item.xpath('coupon_photo').text,
						coupon_max: item.xpath('coupon_max').text.to_i,
						coupon_sold: item.xpath('coupon_sold').text.to_i,
						lat: item.xpath('coupon_lat').text.to_f,
						lng: item.xpath('coupon_lng').text.to_f
					)
				else
					coupons << Coupon.new(
						original_id: item.xpath('coupon_id').text.to_i,
						title: item.xpath('coupon_title').text,
						summary: item.xpath('coupon_summary').text,
						addr: item.xpath('coupon_addr').text,
						teika: item.xpath('coupon_teika').text.to_i,
						kakaku: item.xpath('coupon_kakaku').text.to_i,
						expired: item.xpath('coupon_untilldatetime').text,
						access: item.xpath('coupon_access').text,
						shop_name: item.xpath('coupon_shop').text,
						url: item.xpath('coupon_original_url').text,
				  	photo_url: item.xpath('coupon_photo').text,
						coupon_max: item.xpath('coupon_max').text.to_i,
						coupon_sold: item.xpath('coupon_sold').text.to_i,
						lat: item.xpath('coupon_lat').text.to_f,
						lng: item.xpath('coupon_lng').text.to_f
					)
				end
			end
		end
		Coupon.import coupons unless coupons.empty?
		PageNum.first.increment!(:page_num,1)
=end
	end
end
