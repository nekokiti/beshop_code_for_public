require 'rails_helper'
RSpec.describe CreateCartByChatModeService do
  create_sample_order
  subject { create_cart_by_chat_mode_service.execute }
  let(:create_cart_by_chat_mode_service) do
    described_class.new(line_user: line_user, product: products.first)
  end
  describe "#cart instance" do
    it { expect(subject).to be_an_instance_of(Cart) }
  end
end
