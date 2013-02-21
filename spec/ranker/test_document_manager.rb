require 'spec_helper'

describe DocumentManager, "setters and constructor" do
  it "initializes correctly" do
    document_manager = DocumentManager.new SessionFactory.create_mock_session
    document_manager.homeworks.must_be_instance_of Array
    document_manager.homeworks.must_be_empty
    document_manager.tests.must_be_instance_of Array
    document_manager.tests.must_be_empty
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

describe DocumentManager, "functionality" do
  before do
    @document_manager = DocumentManager.new SessionFactory.create_mock_session
    @document_manager.set_ranklist_document "/url/ranklist"
    @document_manager.set_bonus_codes_document "/url/bonuscodes"
    @document_manager.set_submitted_bonus_codes_document "/url/submittedbonuscodes"
  end

  it "generates bonus codes" do
    @document_manager.generate_bonus_codes 20
    @document_manager.bonus_codes_document.unused_codes_number.must_equal 20
  end

  it "generates bonus codes if nothing left" do
    @document_manager.generate_bonus_codes_if_nothing_left 10
    @document_manager.bonus_codes_document.unused_codes_number.must_equal 10
  end

  it "doesn't generate bonus codes if there are any left" do
    @document_manager.generate_bonus_codes_if_nothing_left 10
    @document_manager.generate_bonus_codes_if_nothing_left 10
    @document_manager.bonus_codes_document.unused_codes_number.must_equal 10  
  end

#  it "checks for new submissions of bonus codes and adds points" do
#  
#  end

#  it "checks homeworks and gives points to the guys that have submitted ontime" do
#
#  end

#  it "checks homeworks and doesn't give points to the guys that haven't submitted ontime" do
#  
#  end

#  it "checks test document and gives 10 points to thos who has 'yes'" do
#  
#  end

#  it "checks test document and doesn't give points to those who has 'no'" do
#  
#  end

end
