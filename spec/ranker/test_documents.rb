require 'spec_helper'

describe HomeworkDocument do
  let (:session) { SessionFactory.create_mock_session }
  let (:date_time) { DateTime.new(2013, 2, 1, 20, 0, 0, '+2') }
  let (:homework) { HomeworkDocument.new session.get_document_by_url("/url/"), 6, date_time }

  it "has correct parameters" do
    homework.url.must_equal "/url/"
    homework.due_date.must_equal date_time
    homework.points.must_equal 6
  end

  it "has method to submit homework" do
    homework.submission_by?('11a', 18).must_equal false
    homework.add_submission DateTime.new(2013, 1, 31, 20, 0, 0, '+2'), '11a', 18, 'John Johnson', 'https://github.com/link/to/repo'
    homework.submission_by?('11a', 18).must_equal true
  end

  it "correctly check if student has submitted homework on time" do
    homework.add_submission DateTime.new(2013, 1, 31, 20, 0, 0, '+2'), '11b', 18, 'John Johnson', 'https://github.com/link/to/repo'
    homework.submission_by?('11b', 18).must_equal true
    homework.ontime_submission_by?('11b', 18).must_equal true
    homework.add_submission DateTime.now, '11a', 10, 'Someone Interesting', 'https://bitbucket.com/interesting/repo'
    homework.submission_by?('11a', 10).must_equal true
    homework.ontime_submission_by?('11a', 10).must_equal false
  end

  it "returns submission by class and number" do
    homework.add_submission DateTime.new(2013, 1, 31, 20, 0, 0), '11b', 18, 'John Johnson', 'https://github.com/link/to/repo'
    submission = homework.submission_by('11b', 18)
    submission.datetime.must_equal DateTime.new(2013, 1, 31, 20, 0, 0)
    submission.klass.must_equal '11b'
    submission.number.must_equal 18
    submission.name.must_equal 'John Johnson'
    submission.repository_link.must_equal 'https://github.com/link/to/repo'
  end

  it "gives all on time submissions" do
    homework.add_submission DateTime.new(2013, 1, 31, 20, 0, 0, '+2'), '11b', 18, 'John Johnson', 'https://github.com/link/to/repo'
    homework.add_submission DateTime.new(2013, 1, 31, 20, 0, 0, '+2'), '11b', 17, 'John Johns', 'https://github.com/link/to/rep'
    homework.add_submission DateTime.now, '11a', 10, 'Someone Interesting', 'https://bitbucket.com/interesting/repo'
    homework.add_submission DateTime.now, '11a', 11, 'Someone Interest', 'https://bitbucket.com/interesting/rep'
    homework.ontime_submissions.size.must_equal 2
    homework.ontime_submissions.one? { |submission| submission.klass == '11b' and submission.number == 18 }.must_equal true
    homework.ontime_submissions.one? { |submission| submission.klass == '11b' and submission.number == 17 }.must_equal true
  end
end

describe TestDocument do
  let (:session) { SessionFactory.create_mock_session }
  let (:date_time) { DateTime.new(2013, 2, 28, 9, 45, 34) }
  let (:date) { Date.new(2013, 2, 28) }
  let (:document) { TestDocument.new session.get_document_by_url("/url/"), date }

  it "has correct parameters" do
    document.url.must_equal "/url/"
    document.date.must_equal date
  end

  it "has correctly working method to add submission" do
    document.submission_by?('11a', 16).must_equal false
    document.add_submission DateTime.now, '11a', 16, 'Ivan Ivanov', CommonConstants::YES
    document.submission_by?('11a', 16).must_equal true
  end

  it "returns correct submission by number and class" do
    document.add_submission date_time, '11a', 16, 'Ivan Ivanov', CommonConstants::NO
    submission = document.submission_by '11a', 16
    submission.datetime.must_equal date_time
    submission.klass.must_equal '11a'
    submission.number.must_equal 16
    submission.name.must_equal 'Ivan Ivanov'
    submission.passed?.must_equal false
  end
end

describe BonusCodesDocument do
  let (:session) { SessionFactory.create_mock_session }
  let (:document) { BonusCodesDocument.new session.get_document_by_url("/url/") }

  it "has correct parameters" do
    document.url.must_equal "/url/"
  end

  it "can generate bonus codes" do
    document.unused_codes_number.must_equal 0
    document.generate_new_codes 10
    document.unused_codes_number.must_equal 10
    document.generate_new_codes 11
    document.unused_codes_number.must_equal 21
  end

  it "generates bonus codes with condition" do
    document.generate_if_nothing_left 8
    document.unused_codes_number.must_equal 8
    document.generate_if_nothing_left 9
    document.unused_codes_number.must_equal 8
  end

  it "has method to get all valid codes" do
    document.generate_new_codes 2
    document.valid_codes.each { |code| code.must_be :!=, '' }
  end

  it "has method to check if a code is valid" do
    document.generate_new_codes 2
    document.valid_codes.each { |code| document.valid?(code).must_equal true }
    document.valid?("NOT VALID CODE AT ALL").must_equal false
  end

  it "has method to set code as used" do
    document.generate_new_codes 3
    code = document.valid_codes[0]
    document.use_code code
    document.valid?(code).must_equal false
    document.unused_codes_number.must_equal 2
    document.use_code code
    document.valid?(code).must_equal false
    document.unused_codes_number.must_equal 2
  end
end

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

describe SubmittedBonusCodesDocument do
  let (:session) { SessionFactory.create_mock_session }
  let (:document) { SubmittedBonusCodesDocument.new session.get_document_by_url("/url/") }

  it "has method to return all submissions" do
    document.must_respond_to :submissions
    document.submissions.must_be_instance_of Array
  end

  it "has method to add submission" do
    document.submit_code "LE CODE", klass: '11a', number: 11
    document.submissions.first.code.must_equal "LE CODE"
    document.submissions.first.klass.must_equal "11a"
    document.submissions.first.number.must_equal 11
    document.submissions.first.checked.must_equal false
  end


  it "has method to check submission" do
    document.submit_code "LE CODE", klass: '11a', number: 11
    document.check_submission document.submissions.first
    document.submissions.first.checked.must_equal true
  end

  it "returns all not checked submissions" do
    document.submit_code "LE CODE", klass: '11a', number: 11
    document.submit_code "LE CODED", klass: '11a', number: 12
    document.check_submission document.submissions.first
    document.not_checked_submissions.must_include document.submissions[1]
    document.not_checked_submissions.wont_include document.submissions[0]
  end

  describe SubmittedBonusCodesDocument::Submission do
    it "implements correct eql? and == operators" do
      document.submit_code "LE CODE", klass: '11a', number: 11
      document.submissions.first == document.submissions.first
      document.submissions.first.eql? document.submissions.first
    end
  end
end
