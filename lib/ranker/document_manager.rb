require 'csv'
require 'ranker/homework_document'
require 'ranker/test_document'
require 'ranker/ranklist_document'
require 'ranker/bonus_codes'
require 'ranker/dateutils'

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

  def serialize(path)
    writer = CSV.open(path, 'w')
    writer << ['RanklistDocument', @ranklist_document.url]
    writer << ['BonusCodesDocument', @bonus_codes_document.url]
    writer << ['SubmittedBonusCodesDocument', @submitted_bonus_codes_document.url]
    @tests.each { |test| writer << ['TestDocument', test.url, DateUtils.date_to_string(test.date)] }
    @homeworks.each { |homework| writer << ['HomeworkDocument', homework.url, homework.points, DateUtils.date_to_string(homework.due_date)] }
    writer.close
  end

  def self.load_from_file(session, path)
    document_manager = DocumentManager.new session
    CSV.open(path, 'r') do |csv|
      csv.each do |row|
        case row[0]
          when 'TestDocument'
            document_manager.add_test_document row[1], DateUtils.string_to_date(row[2])
          when 'HomeworkDocument'
            document_manager.add_homework_document row[1], row[2].to_i, DateUtils.string_to_date(row[3])
          when 'RanklistDocument'
            document_manager.set_ranklist_document row[1]
          when 'BonusCodesDocument'
            document_manager.set_bonus_codes_document row[1]
          when 'SubmittedBonusCodesDocument'
            document_manager.set_submitted_bonus_codes_document row[1]
        end
      end
    end
    document_manager
  end
end
