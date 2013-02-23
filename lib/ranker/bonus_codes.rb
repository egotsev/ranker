require_relative 'document'
require_relative 'common_constants'

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

class SubmittedBonusCodesDocument < Document
  def submit_code(code, student_id)
    @spreadsheet.reload
    @spreadsheet.add_row student_id[:klass], student_id[:number], code, ""
    @spreadsheet.save
  end

  def submissions
    @spreadsheet.reload
    @spreadsheet.rows.map { |row| Submission.new *row }
  end

  def not_checked_submissions
    submissions.select { |submission| !submission.checked }
  end

  def check_submission(submission)
    @spreadsheet.reload
    index = @spreadsheet.rows.find_index { |row| row[0] == submission.klass and row[1] == submission.number.to_s and row[2] == submission.code }
    @spreadsheet[index + 1, 4] = '+'
    @spreadsheet.save
  end

  class Submission
    attr_reader :klass, :number, :code, :checked

    def initialize(klass, number, code, checked)
      @klass, @number, @code, @checked = klass, number.to_i, code, checked == '+'
    end

    def eql?(other)
      if other.is_a? Submission
        @klass == other.klass and @number == other.number and @code == other.code
      else
        false
      end
    end

    alias :== :eql?
  end
end
