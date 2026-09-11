# frozen_string_literal: true
module CsvImport
  extend ActiveSupport::Concern

  MAX_ROW_NUMBER = 30
  PRODUCT_HEADER = {
    '名前' => 'name',
    'クーポン' => 'coupon_flg',
    '送料/手数料無料' => 'no_extra_fee',
    '製品コード' => 'jancode',
    '商品説明文' => 'description',
    'URL' => 'url',
    '価格' => 'price',
    '軽減消費税率対応' => 'reduction_tax',
    '免税対応' => 'tax_free_flg',
    '在庫' => 'quantity',
    '在庫表示' => 'disp_inventory_flg',
    'オススメ' => 'recommend_flg'
  }

  TAG_HEADER = {
    '名前' => 'tag_name',
    'リンク先URL' => 'url'
  }

  def tag_import(file)
    # CSVを1行ずつ解析する
    return 'CSVファイルが選択されていません。' if file.nil?
    return "CSVによる登録は一度に#{CsvImport::MAX_ROW_NUMBER}行までになっています。" if check_row_size(file)
    CSV.foreach(file.path, headers: true, skip_blanks: true, encoding: 'CP932:UTF-8').with_index(2) do |row, row_number|
      ImportTagByCsvWorker.perform_in(10.seconds, row.to_hash, row_number, current_company.id)
    end
    return
  end

  def product_import(file)
    return 'CSVファイルが選択されていません。' if file.nil?
    return "CSVによる登録は一度に#{CsvImport::MAX_ROW_NUMBER}行までになっています。" if check_row_size(file)
    CSV.foreach(file.path, headers: true, skip_blanks: true, encoding: 'CP932:UTF-8').with_index(2) do |row, row_number|
      ImportProductByCsvWorker.perform_in(10.seconds, row.to_hash, row_number, current_company.id)
    end
    return
  end

  private

  def check_row_size(file)
    Roo::Spreadsheet.open(file.path, { csv_options: {encoding: 'CP932'} } ).last_row - 1 > MAX_ROW_NUMBER
  end

end
