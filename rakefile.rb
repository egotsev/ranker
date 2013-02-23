require 'rake/testtask'

Rake::TestTask.new do |t|
  t.libs << "spec/"
  t.libs << "lib/"
  t.test_files = FileList['spec/**/test_*.rb']
  t.verbose = true
  t.warning = true
end
