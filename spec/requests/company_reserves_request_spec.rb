require 'rails_helper'

RSpec.describe CompanyReservesController, type: :request do
  login_company

  before do
    company.update!(occupation_mst_id: OccupationMst::RESERVE)
  end

  let(:valid_attributes) do
    {
      enable_flg: CompanyReserve::RESERVE_PETERN_A,
      reserve_time_as_attributes: [
        {
          start_date: '2020-08-01',
          end_date: '2020-08-05',
          from_time_1: '12:00',
          end_time_1: '14:00',
          from_time_2: '17:00',
          end_time_2: '18:00',
          _destroy: '0'
        },
        {
          start_date: '2020-08-07',
          end_date: '2020-08-14',
          from_time_1: '',
          end_time_1: '',
          from_time_2: '',
          end_time_2: '',
          _destroy: '0'
        },
        {
          start_date: '',
          end_date: '',
          from_time_1: '',
          end_time_1: '',
          from_time_2: '',
          end_time_2: ''
        }
      ],
      reserve_time_b_attributes: {
        days_after_from: '3',
        days_after_to: '5',
        from_time_1: '10:00',
        end_time_1: '17:00',
        from_time_1: '18:00',
        end_time_1: '20:00'
      }
    }
  end

  describe 'GET #new' do
    before do
      get new_company_reserve_url, params: {}
    end
    it 'returns a success response' do
      expect(response).to be_success
    end
    it 'assigns a company_reserve instance' do
      expect(response.body).to include '引き取り日時設定'
    end
  end

  describe 'POST #create' do
    it 'creates a new CompanyReserve' do
      expect {
        post company_reserve_url, params: { company_reserve: valid_attributes }
      }.to change(CompanyReserve, :count).by(1)
      expect(company.reload.company_reserve.reserve_time_as.first.start_date).to \
        eq(valid_attributes[:reserve_time_as_attributes][0][:start_date].to_date)
      expect(company.reload.company_reserve.reserve_time_b.days_after_from).to \
        eq(valid_attributes[:reserve_time_b_attributes][:days_after_from].to_i)
      expect(company.reload.company_reserve.enable_flg).to \
        eq(valid_attributes[:enable_flg].to_i)
    end

    it 'redirects to the created company_reserve' do
        post company_reserve_url, params: { company_reserve: valid_attributes }
      expect(response).to \
        redirect_to(new_company_reserve_url)
    end
  end

  describe 'PUT #update' do
    let(:new_attributes) do
      {
        enable_flg: CompanyReserve::RESERVE_PETERN_A,
        reserve_time_as_attributes: [
          {
            start_date: '2020-09-01',
            end_date: '2020-09-05',
            from_time_1: '12:00',
            end_time_1: '14:00',
            from_time_2: '17:00',
            end_time_2: '18:00',
            _destroy: '0',
            id: ReserveTimeA.first.id
          }
        ]
      }
    end
    it 'updates the requested company_reserve' do
      post company_reserve_url, params: { company_reserve: valid_attributes }
      post company_reserve_url, params: { company_reserve: new_attributes }
      expect(ReserveTimeA.first.start_date).to \
        eq(new_attributes[:reserve_time_as_attributes][0][:start_date].to_date)
      expect(ReserveTimeA.first.end_date).to \
        eq(new_attributes[:reserve_time_as_attributes][0][:end_date].to_date)
    end
  end
end
