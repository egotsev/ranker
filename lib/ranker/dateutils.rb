class DateUtils
  def self.date_to_string(datetime)
    datetime.strftime '%-m/%-d/%Y %H:%M:%S'
  end

  def self.string_to_date(datetime_string)
    DateTime.strptime datetime_string, '%m/%d/%Y %H:%M:%S'
  end
end
