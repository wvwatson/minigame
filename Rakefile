require "bundler/gem_tasks"
require 'rake/testtask'
Rake::TestTask.new do |t|
  t.libs << 'test'
  system("bundle exec rspec spec/")
end

desc "Run tests"
task :default => :test
