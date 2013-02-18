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
