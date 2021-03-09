class HolidayService
  ENDPOINTS = {
    base_url: 'https://date.nager.at',
    next_public_holidays_uri: '/Api/v2/NextPublicHolidays/US'
  }

  def self.upcoming_holidays
    holidays_data = get_info(ENDPOINTS[:next_public_holidays_uri])

    Holiday.create_holidays_from(holidays_data[0..2])
  end

  private
  def self.get_info(uri)
    response = Faraday.get("#{ENDPOINTS[:base_url]}#{uri}")

    JSON.parse(response.body, symbolize_names: true)
  end
end
