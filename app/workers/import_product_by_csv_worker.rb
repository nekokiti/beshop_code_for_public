class ImportProductByCsvWorker
  include Sidekiq::Worker
  include CsvImport
  sidekiq_options retry: false

  def perform(row_hash, row_number, company_id)
    product = Product.new
    # CSV_HEADERのキーを基に、hashに変換する
    row_hash_with_only_exists_keys = row_hash.slice(*PRODUCT_HEADER.keys)
    product.attributes = row_hash_with_only_exists_keys.transform_keys(&PRODUCT_HEADER.method(:[]))
    from_id = Rails.env.test? ? Product.first.id : row_hash["ID"]
    unless Product.find_by_id(from_id)&.image_path&.file.nil?
      CopyCarrierwaveFile::CopyFileService.new(Product.find(from_id), product, :image_path).set_file
    end
    unless Product.find_by_id(from_id)&.movie_path&.file.nil?
      CopyCarrierwaveFile::CopyFileService.new(Product.find(from_id), product, :movie_path).set_file
    end
    product.company_id = company_id
    row_hash["タグ"].split("/").each do |tag|
      product.tags << Tag.find_by(tag_name: tag, company_id: company_id)
    end
    if product.valid?
      product.save
    else
      Rails.logger.debug({:row_num => row_number, :messages => product.errors.full_messages})
    end
  end
end
