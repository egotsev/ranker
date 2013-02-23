require_relative 'homework_document'
require_relative 'test_document'
require_relative 'ranklist_document'
require_relative 'bonus_codes'

class DocumentManager
  attr_reader :homeworks, :tests, :bonus_codes_document, :ranklist_document, :submitted_bonus_codes_document

  def initialize(session)
    @session = session
    @homeworks = []
    @tests = []
  end

  def get_test_document(url)
    @tests.select { |test| test.url == url }.first
  end

  def get_homework_document(url)
    @homeworks.select { |homework| homework.url == url }.first
  end

  def add_homework_document(url, points, due_date)
    @homeworks << HomeworkDocument.new(@session.get_document_by_url(url), points, due_date)
  end

  def add_test_document(url, test_date)
    @tests << TestDocument.new(@session.get_document_by_url(url), test_date)
  end

  def set_bonus_codes_document(url)
    @bonus_codes_document = BonusCodesDocument.new(@session.get_document_by_url(url))
  end

  def set_ranklist_document(url)
    @ranklist_document = RanklistDocument.new(@session.get_document_by_url(url))
  end

  def set_submitted_bonus_codes_document(url)
    @submitted_bonus_codes_document = SubmittedBonusCodesDocument.new(@session.get_document_by_url(url))
  end

  def generate_bonus_codes(count)
    @bonus_codes_document.generate_new_codes count
  end

  def generate_bonus_codes_if_nothing_left(count)
    @bonus_codes_document.generate_if_nothing_left count
  end

  def check_new_bonus_codes_submissions
    @submitted_bonus_codes_document.not_checked_submissions.each do |submission|
      if @bonus_codes_document.valid? submission.code
        @bonus_codes_document.use_code submission.code
        @ranklist_document.increment_points_of submission.klass, submission.number
      end
      @submitted_bonus_codes_document.check_submission submission
    end
  end

  def check_test_results(url)
    get_test_document(url).submissions.each do |submission|
      if submission.passed?
        @ranklist_document.add_points_to_student 10, klass: submission.klass, number: submission.number
      end
    end
  end

  def check_homework(url)
    homework = get_homework_document(url)
    homework.ontime_submissions.each do |submission|
      @ranklist_document.add_points_to_student homework.points, klass: submission.klass, number: submission.number
    end
  end

  def load_from_file(path)
  
  end
end
