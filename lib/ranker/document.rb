class Document
  attr_reader :url

  def initialize(spreadsheet)
    @spreadsheet = spreadsheet
    @spreadsheet.reload
    @url = spreadsheet.url
  end
end
