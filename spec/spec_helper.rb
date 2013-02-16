require 'minitest/spec'
require 'minitest/autorun'
require 'redgreen'
require 'turn'

Dir["#{File.join(File.dirname(__FILE__), '..', 'lib')}**/*.rb"].each { |f| require f }
