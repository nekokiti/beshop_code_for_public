class TagsCsvExportService
require 'csv'

  def initialize(tags)
    @tags = tags
    @csv_column_names = %w(ID 名前 リンク先URL)
  end

  def excute
    csv_data = CSV.generate(encoding: Encoding::SJIS, row_sep: "\r\n", force_quotes: true) do |csv|
      csv << @csv_column_names
      @tags.each do |tag|
        csv_column_values = [
          "#{tag.id}",
          "#{tag.tag_name.try(:sjisable)}",
          "#{tag.url}",
        ]
        tags = ''
        csv << csv_column_values
      end
    end
  end
end
