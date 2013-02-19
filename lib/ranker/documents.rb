class Document
  attr_reader :url

  def initialize(spreadsheet)
    @spreadsheet = spreadsheet
    @url = spreadsheet.url
  end
end

class HomeworkDocument < Document
  attr_reader :due_date

  def initialize(spreadsheet, due_date)
    super(spreadsheet)
    @due_date = due_date
  end
end

class TestDocument < Document
  attr_reader :date

  def initialize(spreadsheet, test_date)
    super(spreadsheet)
    @date = test_date
  end
end

class BonusCodesDocument < Document
  def unused_codes_number
    @spreadsheet.rows.count { |row| row[1] == '' }
  end

  def generate_new_codes(count)
    count.times do
      o = [('a'..'z'), ('A'..'Z')].map{ |i| i.to_a }.flatten
      code = (0...7).map{ o[rand(o.length)] }.join
      @spreadsheet.add_row code, ''
    end
  end

  def generate_if_nothing_left(count)
    generate_new_codes(count) if unused_codes_number == 0
  end
end
