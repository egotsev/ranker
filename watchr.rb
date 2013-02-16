watch(%r{(spec|lib)/(.*/)*.+\.rb}) do
  system 'clear'
  system 'rake test'
end
