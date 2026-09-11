require 'rails_helper'
require 'sidekiq/testing'
RSpec.describe ImportTagByCsvWorker, type: :worker do
  let(:company) { create(:company) }
  let!(:tags) do
    tags = []
    5.times do
      tags << create(:tag,
                     company: company)
    end
    tags
  end
  describe 'ImportTagByCsvWorker' do
    it 'imports tag with csv' do
      Sidekiq::Testing.fake! do
        file = Rack::Test::UploadedFile.new(
          Rails.root.join('spec/support/tags_sample.csv'), 'file/csv'
        )
        CSV.foreach(file.path, headers: true, skip_blanks: true, encoding: 'Shift_JIS:UTF-8').with_index(2) do |row, row_number|
        ImportTagByCsvWorker.new.perform(row.to_hash, row_number, company.id)
        expect(Tag.last.tag_name).to eq 'インポートするテストのタグ'
        end
      end
    end
  end
end
