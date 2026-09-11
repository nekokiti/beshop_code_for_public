require 'rails_helper'

RSpec.describe Tag, :type => :model do
  let(:company) { create(:company) }
  describe "getMyTags" do
    let(:tags) {
      tags = []
      tags_related_with_product = []
      100.times do |i|
        tags << create(:tag, company: company)
        #10番目と20番目と30番目のtagには商品を関連しない
        if (i != 9 && i != 19 && i != 29)
          #[0,1...9,11,12...19,21...29,31...99]
          tags_related_with_product << tags[i]
        end
      end
      create(:product, company: company, tags: tags_related_with_product)
      # 但し30番目のtagには外部url「のみ」設定する
      tags[29].update(url: 'https://www.google.co.jp')
      # また40番目のtagには外部url「も」設定する
      tags[39].update(url: 'https://www.yahoo.co.jp')
      tags
    }
    context "取得したタグの結果が存在する場合" do
      example "与えられたindex以降のタグが50件取得出来る事" do
        res = Tag.getMyTags(company, tags[2].id)
        expect(res).not_to include tags[0]
        expect(res).not_to include tags[1]
        expect(res).to include tags[3]
        expect(res).not_to include tags[9]
        expect(res).not_to include tags[19]
        expect(res).to include tags[29]
        expect(res).to include tags[52]
      end
    end
    context "取得したタグの結果が存在しない場合" do
      example "retrun false" do
        res = Tag.getMyTags(company, tags.last.id)
        expect(res).to be_falsey
      end
    end
  end
end
