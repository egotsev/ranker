require 'ranker/document'

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
