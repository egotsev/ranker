require 'spec_helper'

describe Document do
  let (:session) { SessionFactory.create_mock_session }

  it "initializes correctly" do
    document = Document.new session.get_document_by_url("/url/")
    document.url.must_equal "/url/"
  end
end
