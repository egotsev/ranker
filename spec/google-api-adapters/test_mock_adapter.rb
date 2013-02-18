require 'spec_helper'

describe MockSession do
  it "is created correctly by SessionFactory" do
    session = SessionFactory.create_mock_session
    session.must_be_instance_of(MockSession)
  end

  it "creates MockDocument instances correctly" do
    session = SessionFactory.create_mock_session
    document = session.get_document_by_url "/url/"
    document.must_be_instance_of MockDocument
    document.url.must_equal "/url/"
  end
end

describe MockDocument do
  before do
    @session = SessionFactory.create_mock_session
    @document = @session.get_document_by_url "/url/"
  end

  it "allows access and edit of cells by index" do
    @document[1,1] = "value123"
    @document[1,1].must_equal "value123"
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
end
