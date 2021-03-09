class Holiday
  attr_reader :name, :date

  def initialize(data)
    @name = data[:localName]
    @date = Date.parse(data[:date])
  end

  def pretty_date
    @date.strftime('%A, %B %d, %Y')
  end

  def self.create_holidays_from(holidays_data)
    holidays_data.map do |holiday_data|
      new(holiday_data)
    end
  end
end
