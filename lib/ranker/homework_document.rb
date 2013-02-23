require_relative 'document'
require_relative 'dateutils'

class HomeworkDocument < Document
  attr_reader :due_date, :points

  def initialize(spreadsheet, points, due_date)
    super(spreadsheet)
    @points = points
    @due_date = due_date
  end

  def add_submission(datetime, klass, number, name, repository_link)
    @spreadsheet.reload
    @spreadsheet.add_row DateUtils.date_to_string(datetime), klass, number, name, repository_link
    @spreadsheet.save
  end

  def submission_by?(klass, number)
    @spreadsheet.reload
    @spreadsheet.rows.any? { |row| row[1] == klass and row[2] == number.to_s }
  end

  def ontime_submission_by?(klass, number)
    @spreadsheet.reload
    @spreadsheet.rows.any? { |row| row[1] == klass and row[2] == number.to_s and DateUtils.string_to_date(row[0]) <= @due_date }
  end

  def ontime_submissions
    @spreadsheet.reload
    @spreadsheet.rows.select { |row| DateUtils.string_to_date(row[0]) <= @due_date }.map { |row| Submission.new *row }
  end

  def submission_by(klass, number)
    @spreadsheet.reload
    submissions = @spreadsheet.rows.select { |row| row[1] == klass and row[2] == number.to_s }
    submissions.empty? ? nil : Submission.new(*submissions[0])
  end

  class Submission
    attr_reader :datetime, :klass, :number, :name, :repository_link

    def initialize(datetime, klass, number, name, repository_link)
      @klass, @number, @name, @repository_link = klass, number.to_i, name, repository_link
      @datetime = datetime.is_a?(DateTime) ? datetime : DateUtils.string_to_date(datetime)
    end
  end
end
