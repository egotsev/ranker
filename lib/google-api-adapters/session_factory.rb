require_relative 'mock-adapter/mock_session'
require_relative 'spreadsheets-adapter/google_drive_session'

class SessionFactory
  def self.create_session(username, password)
    GoogleDriveSession.new username, password
  end

  def self.create_mock_session
    MockSession.new
  end
end
