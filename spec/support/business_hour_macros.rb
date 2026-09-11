module BusinessHourMacros
  def create_business_hour
    let(:company) { create(:company, unique_id: "company_with_business_hour") }
    let(:open_time) { Time.zone.local(Time.current.year, Time.current.month, Time.current.day, 9, 30, 00) }
    let(:close_time) { Time.zone.local(Time.current.year, Time.current.month, Time.current.day, 17, 30, 00) }
    let!(:business_hour) do
      create(
        :business_hour,
        company: company,
        open_time: open_time,
        close_time: close_time
      )
    end
  end
end
