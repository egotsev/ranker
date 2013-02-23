require 'spec_helper'

describe RanklistDocument do
  let (:session) { SessionFactory.create_mock_session }
  let (:ranklist) { RanklistDocument.new session.get_document_by_url("/url/") }

  it "has method to return all participants" do
    ranklist.must_respond_to :participants
    ranklist.participants.must_be_instance_of Array
  end

  it "allows adding student" do
    ranklist.add_or_update_student '11a', 1, "Alexander O."
    ranklist.participants.count { |student| student.klass == '11a' and student.number == 1 }.must_equal 1
  end

  it "returns participants by klass and number" do
    ranklist.participant('11a', 1).must_be_nil
    ranklist.add_or_update_student '11a', 1, "Alexander O."
    participant = ranklist.participant '11a', 1
    participant.klass.must_equal '11a'
    participant.number.must_equal 1
    participant.name.must_equal "Alexander O."
  end

  it "doesn't allow adding one student two times" do
    ranklist.participants.count { |student| student.klass == '11a' and student.number == 1 and student.name == "Alexander O." }.must_equal 0
    ranklist.add_or_update_student '11a', 1, "Alexander O."
    ranklist.add_or_update_student '11a', 1, "Alexander O."
    ranklist.participants.count { |student| student.klass == '11a' and student.number == 1 and student.name == "Alexander O." }.must_equal 1
    ranklist.add_or_update_student '11a', 1, "Alexander Otsetov"
    ranklist.participants.count { |student| student.klass == '11a' and student.number == 1 }.must_equal 1
  end

  it "allows updating student's name" do
    ranklist.add_or_update_student '11a', 1, "Alexander O."
    ranklist.participants.count { |student| student.klass == '11a' and student.number == 1 and student.name == "Alexander O." }.must_equal 1
    ranklist.add_or_update_student '11a', 1, "Alexander Otsetov"
    ranklist.participants.count { |student| student.klass == '11a' and student.number == 1 and student.name == "Alexander O." }.must_equal 0
    ranklist.participants.count { |student| student.klass == '11a' and student.number == 1 and student.name == "Alexander Otsetov" }.must_equal 1
  end

  it "increments the points of a student correctly" do
    ranklist.add_or_update_student '11a', 2, "Boris K."
    ranklist.increment_points_of '11a', 2
    ranklist.participant('11a', 2).points.must_equal 1
    ranklist.increment_points_of '11a', 2
    ranklist.participant('11a', 2).points.must_equal 2
  end

  it "adds points to a student correctly" do
    ranklist.add_or_update_student '11a', 11, "Emil Gotsev"
    ranklist.add_points_to_student 10, klass: '11a', number: 11
    ranklist.participant('11a', 11).points.must_equal 10
    ranklist.increment_points_of '11a', 11
    ranklist.participant('11a', 11).points.must_equal 11
  end

  it "preserves student points when updating the name" do
    ranklist.add_or_update_student '11a', 11, "Emil Gotsev"
    ranklist.add_points_to_student 10, klass: '11a', number: 11
    ranklist.add_or_update_student '11a', 11, "Emil I. Gotsev"
    ranklist.participant('11a', 11).points.must_equal 10
  end
end
