require_relative 'mock-adapter/mock_session'

class SessionFactory
  def self.create_session(username, password)
    # here we'll use the actual API
  end

  def self.create_mock_session
    MockSession.new
  end
end
