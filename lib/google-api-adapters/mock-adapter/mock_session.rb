class MockSession
  def get_document_by_url(url)
    MockDocument.new url
  end
end

class MockDocument
  attr_reader :url

  def initialize(url)
    @url = url
    @cells = []
  end

  def [](row, col)
    @cells[row - 1] ||= []
    @cells[row - 1][col - 1] || ''
  end

  def []=(row, col, value)
    @cells[row - 1] ||= []
    @cells[row - 1][col - 1] = value
    @dirty = true
  end

  def rows
    @cells
  end

  def reload
    #for the mock this method does nothing
  end

  def save
    @dirty = false
  end

  def dirty?
    @dirty
  end

  def add_row(*args)
    @cells << args
  end
end
