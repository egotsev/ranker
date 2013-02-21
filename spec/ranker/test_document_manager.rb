require 'spec_helper'

describe DocumentManager do
  it "initializes correctly" do
    DocumentManager.new SessionFactory.create_mock_session
  end

  let (:doc_manager) { DocumentManager.new SessionFactory.create_mock_session }
  let (:date_time) { DateTime.now }
  
  it "has method to create homework document from url" do
    doc_manager.add_homework_document "url", date_time
    doc_manager.homeworks.any? { |homework| homework.url == "url" }.must_equal true
    doc_manager.homeworks.any? { |homework| homework.due_date == date_time }.must_equal true
  end

  it "has method to add existing test document" do
    doc_manager.add_test_document "/url?test=true", date_time
    doc_manager.tests.any? { |test| test.url == "/url?test=true"}.must_equal true
    doc_manager.tests.any? { |test| test.date == date_time }.must_equal true
  end

  it "has method to set the document for bonus codes" do
    doc_manager.bonus_codes_document.must_be_nil
    doc_manager.set_bonus_codes_document "/url/bonuspoints"
    doc_manager.bonus_codes_document.url.must_equal "/url/bonuspoints"
  end

  it "has method to set the ranklist document" do
    doc_manager.ranklist_document.must_be_nil
    doc_manager.set_ranklist_document "/url/ranklist"
    doc_manager.ranklist_document.url.must_equal "/url/ranklist"
  end

  it "has method to set the submitted bonus code document" do
    doc_manager.submitted_bonus_codes_document.must_be_nil
    doc_manager.set_submitted_bonus_codes_document "/url/submittedbonuscodes"
    doc_manager.submitted_bonus_codes_document.url.must_equal "/url/submittedbonuscodes"
  end
end
