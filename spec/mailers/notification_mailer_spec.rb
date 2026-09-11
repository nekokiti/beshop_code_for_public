require "rails_helper"

RSpec.describe NotificationMailer, type: :mailer do
  create_sample_order
  let!(:extra_message) { create(:extra_message, company: company, extra_message: 'hogehoge') }
  after(:all) do
    ActionMailer::Base.deliveries.clear
  end
  describe "send mail to company" do
    let(:mail) { NotificationMailer.send_notification_to_company(order) }
    describe 'NotificationMailer #send_notification_to_company as creating' do
      it { expect(ActionMailer::Base.deliveries).to be_empty }
      it 'prepare mail' do
        expect(mail.subject).to eq I18n.t('mailer.company.title')
        expect(mail.to.first).to eq company.email
        expect(mail.body.encoded).to include company.company_name
      end
    end
    describe 'NotificationMailer #send_notification_to_company as sending' do
      before do
        mail.deliver
      end
      let(:sent_mail) { ActionMailer::Base.deliveries.last }
      it { expect(ActionMailer::Base.deliveries.count).to eq 1 }
      it 'sent mail' do
        expect(sent_mail.subject).to eq I18n.t('mailer.company.title')
        expect(sent_mail.to.first).to eq company.email
        expect(sent_mail.body.encoded).to include company.company_name
      end
    end
  end
  describe "send mail to user" do
    context "default occupation" do
      let(:mail) { NotificationMailer.send_confirm_to_user(order) }
      it { expect(ActionMailer::Base.deliveries).to be_empty }
      describe 'NotificationMailer #send_confirm_to_user as creating' do
        it 'prepare mail' do
          expect(mail.subject).to eq I18n.t('mailer.user.title')
          expect(mail.to.first).to eq line_user.email
          expect(mail.body.encoded).to include line_user.first_name
          expect(mail.body.encoded).to include line_user.last_name
          expect(mail.body.encoded).to include '送料'
          expect(mail.body.encoded).to include '手数料'
          expect(mail.body.encoded).to include '内クーポン利用額'
          expect(mail.body.encoded).to include company.extra_message.extra_message
        end
      end
      describe 'NotificationMailer #send_confirm_to_user as sending' do
        before do
          mail.deliver
        end
        let(:sent_mail) { ActionMailer::Base.deliveries.last }
        it { expect(ActionMailer::Base.deliveries.count).to eq 1 }
        it 'sent mail' do
          expect(sent_mail.subject).to eq I18n.t('mailer.user.title')
          expect(sent_mail.to.first).to eq line_user.email
          expect(sent_mail.body.encoded).to include line_user.first_name
          expect(sent_mail.body.encoded).to include line_user.last_name
          expect(sent_mail.body.encoded).to include '送料'
          expect(sent_mail.body.encoded).to include '手数料'
          expect(sent_mail.body.encoded).to include '内クーポン利用額'
          expect(sent_mail.body.encoded).to include company.extra_message.extra_message
        end
      end
      let(:test_mail) { NotificationMailer.send_confirm_to_user_test(company) }
      describe 'NotificationMailer #send_confirm_to_user_test as creating' do
        it { expect(ActionMailer::Base.deliveries).to be_empty }
        it 'prepare test_mail' do
          expect(test_mail.subject).to eq I18n.t('mailer.company.test_title')
          expect(test_mail.body.encoded).to include '送料'
          expect(test_mail.body.encoded).to include '手数料'
          expect(test_mail.body.encoded).to include '内クーポン利用額'
          expect(test_mail.body.encoded).to include company.extra_message.extra_message
        end
      end
      describe 'NotificationMailer #send_confirm_to_user_test as sending' do
        before do
          test_mail.deliver
        end
        let(:sent_test_mail) { ActionMailer::Base.deliveries.last }
        it { expect(ActionMailer::Base.deliveries.count).to eq 1 }
        it 'sent test_mail' do
          expect(sent_test_mail.subject).to eq I18n.t('mailer.company.test_title')
          expect(sent_test_mail.body.encoded).to include '送料'
          expect(sent_test_mail.body.encoded).to include '手数料'
          expect(sent_test_mail.body.encoded).to include '内クーポン利用額'
          expect(sent_test_mail.body.encoded).to include company.extra_message.extra_message
        end
      end
    end
    context "Reserve occupation" do
      before do
        reserve_times = ['2021-05-26', '09:00', '21:00']
        ReserveDetail.upsert(cart, order, reserve_times)
        company.update!(occupation_mst_id: OccupationMst::RESERVE)
      end
      let(:mail2) { NotificationMailer.send_confirm_to_user(order) }
      it { expect(ActionMailer::Base.deliveries).to be_empty }
      describe 'NotificationMailer #send_confirm_to_user as creating' do
        it 'prepare mail' do
          expect(mail2.body.encoded).not_to include '送料'
          expect(mail2.body.encoded).not_to include '手数料'
          expect(mail2.body.encoded).not_to include '内クーポン利用額'
          expect(mail2.body.encoded).to include 'お受け取り予定日'
          expect(mail2.body.encoded).to include 'お受け取り予定時刻'
          expect(mail2.body.encoded).to include '注文の取り消しや数量変更は該当店舗へお電話にてご連絡ください。'
        end
      end
      describe 'NotificationMailer #send_confirm_to_user as sending' do
        before do
          mail2.deliver
        end
        let(:sent_mail2) { ActionMailer::Base.deliveries.last }
        it { expect(ActionMailer::Base.deliveries.count).to eq 1 }
        it 'sent mail' do
          expect(mail2.body.encoded).not_to include '送料'
          expect(mail2.body.encoded).not_to include '手数料'
          expect(mail2.body.encoded).not_to include '内クーポン利用額'
          expect(mail2.body.encoded).to include 'お受け取り予定日'
          expect(mail2.body.encoded).to include 'お受け取り予定時刻'
          expect(mail2.body.encoded).to include '注文の取り消しや数量変更は該当店舗へお電話にてご連絡ください。'
        end
      end
      let(:test_mail2) { NotificationMailer.send_confirm_to_user_test(company) }
      describe 'NotificationMailer #send_confirm_to_user_test as creating' do
        it { expect(ActionMailer::Base.deliveries).to be_empty }
        it 'prepare test_mail' do
          expect(test_mail2.subject).to eq I18n.t('mailer.company.test_title')
          expect(test_mail2.body.encoded).not_to include '送料'
          expect(test_mail2.body.encoded).not_to include '手数料'
          expect(test_mail2.body.encoded).not_to include '内クーポン利用額'
          expect(test_mail2.body.encoded).to include 'お受け取り予定日'
          expect(test_mail2.body.encoded).to include 'お受け取り予定時刻'
          expect(test_mail2.body.encoded).to include '注文の取り消しや数量変更は該当店舗へお電話にてご連絡ください。'
          expect(test_mail2.body.encoded).to include company.extra_message.extra_message
        end
      end
      describe 'NotificationMailer #send_confirm_to_user_test as sending' do
        before do
          test_mail2.deliver
        end
        let(:sent_test_mail2) { ActionMailer::Base.deliveries.last }
        it { expect(ActionMailer::Base.deliveries.count).to eq 1 }
        it 'sent test_mail' do
          expect(sent_test_mail2.subject).to eq I18n.t('mailer.company.test_title')
          expect(sent_test_mail2.body.encoded).not_to include '送料'
          expect(sent_test_mail2.body.encoded).not_to include '手数料'
          expect(sent_test_mail2.body.encoded).not_to include '内クーポン利用額'
          expect(sent_test_mail2.body.encoded).to include 'お受け取り予定日'
          expect(sent_test_mail2.body.encoded).to include 'お受け取り予定時刻'
          expect(sent_test_mail2.body.encoded).to include '注文の取り消しや数量変更は該当店舗へお電話にてご連絡ください。'
          expect(sent_test_mail2.body.encoded).to include company.extra_message.extra_message
        end
      end
    end
  end
end
