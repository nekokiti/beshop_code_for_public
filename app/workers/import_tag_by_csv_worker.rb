class ImportTagByCsvWorker
  include Sidekiq::Worker
  include CsvImport

  def perform(row_hash, row_number, company_id)
    tag = Tag.new
    # CSV_HEADERのキーを基に、hashに変換する
    row_hash_with_only_exists_keys = row_hash.slice(*TAG_HEADER.keys)
    tag.attributes = row_hash_with_only_exists_keys.transform_keys(&TAG_HEADER.method(:[]))
    from_id = Rails.env.test? ? Tag.first.id : row_hash["ID"]
    unless Tag.find_by_id(from_id)&.image_path&.file.nil?
      CopyCarrierwaveFile::CopyFileService.new(Tag.find(from_id), tag, :image_path).set_file
    end
    tag.company_id = company_id
    if tag.valid?
      tag.save
    else
      Rails.logger.debug({:row_num => row_number, :messages => tag.errors.full_messages})
    end
  end
end
