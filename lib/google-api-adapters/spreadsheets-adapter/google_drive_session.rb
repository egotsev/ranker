require 'google_drive'

class GoogleDriveSession
  def initialize(mail, password)
    @session = GoogleDrive.login(mail, password)
  end

  def get_document_by_url(url)
    GoogleDriveSpreadsheet.new @session.spreadsheet_by_url(url).worksheets[0]
  end
end

class GoogleDriveSpreadsheet
  def initialize(worksheet)
    @worksheet = worksheet
  end

  def [](row, col)
    @worksheet[row + 1, col]
  end

  def []=(row, col, value)
    @worksheet[row + 1, col] = value
  end

  def rows
    @worksheet.rows.drop 1
  end

  def reload
    @worksheet.reload
  end

  def save
    @worksheet.save
  end

  def dirty?
    @worksheet.dirty?
  end

  def add_row(*args)
    row = @worksheet.num_rows + 1
    args.size.times { |i| @worksheet[row, i + 1] = args[i] }
  end
end
