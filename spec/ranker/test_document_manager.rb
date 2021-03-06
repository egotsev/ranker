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
    doc_manager.add_homework_document "url", 6, date_time
    doc_manager.homeworks.any? { |homework| homework.url == "url" }.must_equal true
    doc_manager.homeworks.any? { |homework| homework.due_date == date_time }.must_equal true
    doc_manager.homeworks.any? { |homework| homework.points == 6 }.must_equal true
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

  it "returns test document for given url" do
    doc_manager.add_test_document "/url?test=true", date_time
    doc_manager.get_test_document("/url?test=true").url.must_equal "/url?test=true"
    doc_manager.tests.must_include doc_manager.get_test_document("/url?test=true")
  end

  it "returns homework document for givev url" do
    doc_manager.add_homework_document "/url?hw=true", 10, date_time
    doc_manager.get_homework_document("/url?hw=true").url.must_equal "/url?hw=true"
    doc_manager.homeworks.must_include doc_manager.get_homework_document("/url?hw=true")
  end
end

describe DocumentManager, "functionality" do
  before do
    @document_manager = DocumentManager.new SessionFactory.create_mock_session
    @document_manager.set_ranklist_document "/url/ranklist"
    @document_manager.ranklist_document.add_or_update_student '11a', 1, "Alex A."
    @document_manager.ranklist_document.add_or_update_student '11a', 2, "Ivan I."
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

  it "checks for new submissions of bonus codes and adds points when there are matches" do
    @document_manager.generate_bonus_codes 1
    code = @document_manager.bonus_codes_document.valid_codes.first
    @document_manager.submitted_bonus_codes_document.submit_code code, klass: '11a', number: 1
    @document_manager.check_new_bonus_codes_submissions
    @document_manager.bonus_codes_document.unused_codes_number.must_equal 0
    @document_manager.ranklist_document.participant('11a', 1).points.must_equal 1
    @document_manager.submitted_bonus_codes_document.not_checked_submissions.size.must_equal 0
  end

  it "checks for new submission of bonus codes and doesn't add points when there is no match" do
    @document_manager.generate_bonus_codes 2
    @document_manager.submitted_bonus_codes_document.submit_code "LE FAKE CODE", klass: '11a', number: 2
    @document_manager.check_new_bonus_codes_submissions
    @document_manager.bonus_codes_document.unused_codes_number.must_equal 2
    @document_manager.ranklist_document.participant('11a', 2).points.must_equal 0
    @document_manager.submitted_bonus_codes_document.not_checked_submissions.size.must_equal 0
  end

  it "doesn't give points on second check for submitted bonus codes" do
    @document_manager.generate_bonus_codes 2
    code = @document_manager.bonus_codes_document.valid_codes.first
    @document_manager.submitted_bonus_codes_document.submit_code code, klass: '11a', number: 1
    @document_manager.check_new_bonus_codes_submissions
    @document_manager.ranklist_document.participant('11a', 1).points.must_equal 1
    @document_manager.check_new_bonus_codes_submissions
    @document_manager.ranklist_document.participant('11a', 1).points.must_equal 1
  end

  it "checks homeworks and gives points to the guys that have submitted ontime" do
    @document_manager.add_homework_document "/url/hw2", 6, DateTime.new(2013, 2, 20, 20, 0, 0)
    homework2_document = @document_manager.get_homework_document "/url/hw2"
    homework2_document.add_submission DateTime.new(2013, 2, 19, 19, 59, 59), '11a', 1, 'Alex A.', 'http://github.com/alex_a/hw2'
    homework2_document.add_submission DateTime.new(2013, 2, 20, 20, 0, 0), '11a', 2, 'Ivan I.', 'http://github.com/ivan_i/hw2'
    @document_manager.check_homework "/url/hw2"
    @document_manager.ranklist_document.participant('11a', 1).points.must_equal 6
    @document_manager.ranklist_document.participant('11a', 2).points.must_equal 6
  end

  it "checks homeworks and doesn't give points to the guys that haven't submitted ontime" do
    @document_manager.add_homework_document "/url/hw2", 6, DateTime.new(2013, 2, 20, 20, 0, 0)
    homework2_document = @document_manager.get_homework_document "/url/hw2"
    homework2_document.add_submission DateTime.new(2013, 2, 21, 10, 59, 59), '11a', 1, 'Alex A.', 'http://github.com/alex_a/hw2'
    homework2_document.add_submission DateTime.new(2013, 2, 20, 20, 0, 1), '11a', 2, 'Ivan I.', 'http://github.com/ivan_i/hw2'
    @document_manager.check_homework "/url/hw2"
    @document_manager.ranklist_document.participant('11a', 1).points.must_equal 0
    @document_manager.ranklist_document.participant('11a', 2).points.must_equal 0
  end

  it "checks test document and gives 10 points to those who has 'yes'" do
    @document_manager.add_test_document "/url/test1", Date.new(2013, 2, 22)
    @test1_document = @document_manager.get_test_document "/url/test1"
    @test1_document.add_submission DateTime.now, '11a', 1, "Alex A.", CommonConstants::YES
    @document_manager.check_test_results "/url/test1"
    @document_manager.ranklist_document.participant('11a', 1).points.must_equal 10
  end

  it "checks test document and doesn't give points to those who has 'no'" do
    @document_manager.add_test_document "/url/test1", Date.new(2013, 2, 22)
    @test1_document = @document_manager.get_test_document "/url/test1"
    @test1_document.add_submission DateTime.now, '11a', 1, "Alex A.", CommonConstants::NO
    @document_manager.check_test_results "/url/test1"
    @document_manager.ranklist_document.participant('11a', 1).points.must_equal 0
  end

  it "serializes to file" do
    @document_manager.add_test_document "/url/test1", Date.new(2013, 2, 22)
    @document_manager.add_homework_document "/url/hw1", 6, DateTime.new(2013, 2, 20, 20, 0, 0)
    @document_manager.serialize("store/documents.csv")
    CSV.open("store/documents.csv") do |csv|
      csv.each do |row|
        case row[0]
          when 'TestDocument'
            row[1].must_equal "/url/test1"
            row[2].must_equal DateUtils.date_to_string(Date.new(2013, 2, 22))
          when 'HomeworkDocument'
            row[1].must_equal "/url/hw1"
            row[2].must_equal 6.to_s
            row[3].must_equal DateUtils.date_to_string(DateTime.new(2013, 2, 20, 20, 0, 0))
          when 'RanklistDocument'
            row[1].must_equal "/url/ranklist"
          when 'BonusCodesDocument'
            row[1].must_equal "/url/bonuscodes"
          when 'SubmittedBonusCodesDocument'
            row[1].must_equal "/url/submittedbonuscodes"
        end
      end
    end
  end

  it "loads from file" do
    @document_manager.add_test_document "/url/test1", Date.new(2013, 2, 22)
    @document_manager.add_homework_document "/url/hw1", 6, DateTime.new(2013, 2, 20, 20, 0, 0)
    @document_manager.serialize("store/documents.csv")
    document_manager_serialization = File.open("store/documents.csv", 'rb').read
    loaded_document_manager = DocumentManager.load_from_file(SessionFactory.create_mock_session, "store/documents.csv")
    loaded_document_manager.serialize("store/documents.csv")
    loaded_document_manager_serialization = File.open("store/documents.csv", 'rb').read
    document_manager_serialization.must_equal loaded_document_manager_serialization
  end
end
