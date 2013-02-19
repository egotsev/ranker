require 'spec_helper'

describe HomeworkDocument do
  let (:session) { SessionFactory.create_mock_session }
  let (:date_time) { DateTime.now }
  let (:homework) { HomeworkDocument.new session.get_document_by_url("/url/"), date_time }

  it "has correct parameters" do
    homework.url.must_equal "/url/"
    homework.due_date.must_equal date_time
  end
end

describe TestDocument do
  let (:session) { SessionFactory.create_mock_session }
  let (:date_time) { DateTime.now }
  let (:document) { TestDocument.new session.get_document_by_url("/url/"), date_time }

  it "has correct parameters" do
    document.url.must_equal "/url/"
    document.date.must_equal date_time
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
end
