require 'spec_helper'

describe MockSession do
  it "is created correctly by SessionFactory" do
    session = SessionFactory.create_mock_session
    session.must_be_instance_of(MockSession)
  end

  it "creates MockDocument instances correctly" do
    session = SessionFactory.create_mock_session
    document = session.get_document_by_url "/url/"
    document.must_be_instance_of MockSpreadsheet
    document.url.must_equal "/url/"
  end
end

describe MockSpreadsheet do
  before do
    @session = SessionFactory.create_mock_session
    @document = @session.get_document_by_url "/url/"
  end

  it "allows access and edit of cells by index" do
    @document[1,1] = "value123"
    @document[1,1].must_equal "value123"
    @document[3,3] = "new value"
    @document[3,3].must_equal "new value"
  end

  it "has methods save and reload (from Drive)" do
    @document.reload
    @document[1,1] = "value123"
    @document.save
    @document[1,1].must_equal "value123"
  end

  it "has a properly working dirty? method" do
    @document.save
    @document.dirty?.must_equal false
    @document[1,1] = -1;
    @document.dirty?.must_equal true
    @document.save
    @document.dirty?.must_equal false
  end

  it "has a rows method" do
    @document.rows.must_be_instance_of Array
  end

  it "returns empty strings for empty cells" do
    @document[1,1].must_equal ''
    @document[2,3].must_equal ''
  end

  it "allows adding new rows" do
    @document.add_row "12", "24", "string"
    @document[1,1].must_equal "12"
    @document[1,2].must_equal "24"
    @document[1,3].must_equal "string"
    @document.add_row 1234
    @document[2,1].must_equal "1234"
  end
end
