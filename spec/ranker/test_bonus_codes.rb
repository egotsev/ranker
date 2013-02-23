require 'spec_helper'

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
