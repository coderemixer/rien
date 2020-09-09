# frozen_string_literal: true

require 'bundler/gem_tasks'
require 'rake/testtask'
require 'ci/reporter/rake/minitest'

Rake::TestTask.new(:minitest) do |t|
  t.libs << 'lib'
  t.libs << 'test'
  t.test_files = FileList['test/**/*_test.rb']
end

task minitest: 'ci:setup:minitest'
task default: 'minitest'
