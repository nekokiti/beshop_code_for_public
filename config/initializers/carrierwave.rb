if Rails.env.development? || Rails.env.test?
	CarrierWave.configure do |config|
	end
elsif Rails.env.production?
	CarrierWave.configure do |config|
		config.fog_credentials = {
			provider: 'AWS',
			aws_access_key_id: 'AKIAI62YMH6YGZ7TB62A',
			aws_secret_access_key: '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',
			region: 'ap-northeast-1'
		}
		config.fog_directory	= ENV['S3_BUCKET']
		config.cache_storage = :fog
	end
end
