require 'spec_helper'

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

  it "gives all submissions" do
    document.add_submission DateTime.now, '11a', 16, 'Ivan Ivanov', CommonConstants::YES
    document.add_submission DateTime.now, '11a', 16, 'Ivan Ivanov', CommonConstants::YES
    document.submissions.size.must_equal 2
    document.submissions.must_be_instance_of Array
  end

  it "returns nil when there's no submission bu student" do
    document.add_submission date_time, '11a', 16, 'Ivan Ivanov', CommonConstants::NO
    document.submission_by('11a', 17).must_be_nil
  end
end
