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

class BonusPointsDocument < Document
end
