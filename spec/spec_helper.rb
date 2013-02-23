require 'minitest/spec'
require 'minitest/autorun'
require 'redgreen'
require 'turn'
require 'csv'

Dir["#{File.join(File.dirname(__FILE__), '..', 'lib')}/**/*.rb"].each { |f| require f }
