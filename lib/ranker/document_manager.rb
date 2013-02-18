class DocumentManager
  attr_reader :homeworks, :tests, :bonus_points_document

  def initialize(session)
    @session = session
    @homeworks = []
    @tests = []
  end

  def add_homework_document(url, due_date)
    @homeworks << HomeworkDocument.new(@session.get_document_by_url(url), due_date)
  end

  def add_test_document(url, test_date)
    @tests << TestDocument.new(@session.get_document_by_url(url), test_date)
  end

  def set_bonus_points_document(url)
    @bonus_points_document = BonusPointsDocument.new(@session.get_document_by_url(url))
  end
end
