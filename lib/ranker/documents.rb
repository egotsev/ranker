require_relative 'dateutils'
require_relative 'common_constants'

class Document
  attr_reader :url

  def initialize(spreadsheet)
    @spreadsheet = spreadsheet
    @spreadsheet.reload
    @url = spreadsheet.url
  end
end

class HomeworkDocument < Document
  attr_reader :due_date

  def initialize(spreadsheet, due_date)
    super(spreadsheet)
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

  def all_submissions_ontime
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

class BonusCodesDocument < Document
  def unused_codes_number
    @spreadsheet.reload
    @spreadsheet.rows.count { |row| row[1] == '' }
  end
  
  def valid_codes
    @spreadsheet.rows.select { |row| row[0] != '' and row[1] == '' }.map { |row| row[0] }
  end

  def generate_new_codes(count)
    @spreadsheet.reload
    count.times do
      o = [('a'..'z'), ('A'..'Z')].map{ |i| i.to_a }.flatten
      code = (0...7).map{ o[rand(o.length)] }.join
      @spreadsheet.add_row code, ''
    end
    @spreadsheet.save
  end

  def generate_if_nothing_left(count)
    generate_new_codes(count) if unused_codes_number == 0
  end

  def valid?(code)
    @spreadsheet.reload
    valid_codes.include? code
  end

  def use_code(code)
    if valid?(code)
      index = @spreadsheet.rows.find_index { |row| row[0] == code }
      @spreadsheet[index + 1, 2] = CommonConstants::USED
      @spreadsheet.save
    end
  end
end

class RanklistDocument < Document
  def add_or_update_student(klass, number, name)
    @spreadsheet.reload
    index = @spreadsheet.rows.find_index { |row| row[0] == klass and row[1] == number.to_s }
    unless index
      @spreadsheet.add_row klass, number, name, 0
    else
      @spreadsheet[index + 1, 1] = klass
      @spreadsheet[index + 1, 2] = number
      @spreadsheet[index + 1, 3] = name
    end
    @spreadsheet.save
  end

  def increment_points_of(klass, number)
    add_points_to_student 1, klass: klass, number: number
  end

  def add_points_to_student(points, student)
    @spreadsheet.reload
    index = @spreadsheet.rows.find_index { |row| row[0] == student[:klass] and row[1] == student[:number].to_s }
    @spreadsheet[index + 1, 4] = @spreadsheet[index + 1, 4].to_i + points
    @spreadsheet.save
  end

  def participants
    @spreadsheet.reload
    @spreadsheet.rows.map { |row| Participant.new(row[0], row[1], row[2], row[3]) }
  end
  
  def participant(klass, number)
    participants.select { |participant| participant.klass == klass and participant.number == number }.first
  end

  class Participant
    attr_reader :klass, :number, :name, :points

    def initialize(klass, number, name, points)
      @klass, @number, @name, @points = klass, number.to_i, name, points.to_i
    end
  end
end
