# encoding: utf-8

require 'rubygems'
require 'bundler'
begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end
require 'rake'
$: << File.expand_path('../lib', __FILE__)
require 'glt'

require 'jeweler'
Jeweler::Tasks.new do |gem|
  # gem is a Gem::Specification... see http://docs.rubygems.org/read/chapter/20 for more options
  gem.name = "glt"
  gem.homepage = "http://github.com/lemarsu/glt"
  gem.license = "MIT"
  gem.summary = %Q{Get last torrent}
  gem.description = %Q{Simple utility to download files from an RSS feed.}
  gem.email = "ch.ruelle@lemarsu.com"
  gem.authors = ["LeMarsu"]
  gem.version = "#{Glt::Version}" # I know, it's stupid, but they want a not frozen string...
  # dependencies defined in Gemfile
end
Jeweler::RubygemsDotOrgTasks.new

require 'rspec/core'
require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec) do |spec|
  spec.pattern = FileList['spec/**/*_spec.rb']
end

RSpec::Core::RakeTask.new(:rcov) do |spec|
  spec.pattern = 'spec/**/*_spec.rb'
  spec.rcov = true
end

task :default => :spec

require 'yard'
YARD::Rake::YardocTask.new

task 'clean' do
  %w[pkg doc rdoc coverage].each do |dir|
    FileUtils.rm_rf dir
  end
end
