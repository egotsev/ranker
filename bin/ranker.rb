$LOAD_PATH.unshift('../lib')

require 'ranker'

puts 'enter google email: '
email = gets.chomp
password = ask('enter password') { |q| q.echo = false }

document_manager = DocumentManager.load_from_file(SessionFactory.create_session(email, password), '../store/documents.csv')
