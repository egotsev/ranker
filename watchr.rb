watch('(.+/)*.*\.rb') do
  system 'clear'
  system 'rake test'
end
