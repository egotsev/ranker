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
