require 'spec_helper'

describe DateUtils do
  it "converts dates into strings" do
    datetime = DateTime.new(2013, 1, 31, 20, 0, 0)
    datetime_string = DateUtils.date_to_string datetime
    datetime_string.must_equal "1/31/2013 20:00:00"
  end

  it "converts strings into dates" do
    datetime_string = "1/1/2012 20:01:59"
    datetime = DateUtils.string_to_date "1/1/2012 20:01:59"
    datetime.must_equal DateTime.new(2012, 1, 1, 20, 1, 59)
  end
end
