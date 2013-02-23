require_relative 'document'
require_relative 'dateutils'
require_relative 'common_constants'

class TestDocument < Document
  attr_reader :date

  def initialize(spreadsheet, test_date)
    super(spreadsheet)
    @date = test_date
  end

  def add_submission(datetime, klass, number, name, passed)
    @spreadsheet.reload
    @spreadsheet.add_row DateUtils.date_to_string(datetime), klass, number, name, passed
    @spreadsheet.save
  end

  def submission_by?(klass, number)
    @spreadsheet.reload
    @spreadsheet.rows.any? { |row| row[1] == klass and row[2] == number.to_s }
  end

  def submission_by(klass, number)
    @spreadsheet.reload
    submissions = @spreadsheet.rows.select { |row| row[1] == klass and row[2] == number.to_s }
    submissions.empty? ? nil : Submission.new(*submissions[0])
  end

  def submissions
    @spreadsheet.rows.map { |row| Submission.new *row }
  end

  class Submission
    attr_reader :datetime, :klass, :number, :name

    def initialize(datetime, klass, number, name, passed)
      @klass, @number, @name = klass, number.to_i, name
      @passed = passed == CommonConstants::YES ? true : false
      @datetime = datetime.is_a?(DateTime) ? datetime : DateUtils.string_to_date(datetime)
    end

    def passed?
      @passed
    end
  end
end
