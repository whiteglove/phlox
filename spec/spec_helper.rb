ENV['RAILS_ENV'] || 'test'

require File.expand_path("../dummy/config/environment.rb", __FILE__)
require 'rspec/rails'
require 'rspec/autorun'

require 'simplecov'
SimpleCov.start do
  add_filter "/spec/"
  coverage_dir("../#{File.split(ENV['CC_BUILD_ARTIFACTS'])[1]}/coverage") if ENV['CC_BUILD_ARTIFACTS']
end

# Load support files
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each { |f| require f }

RSpec.configure do |config|
  config.order = "random"
end

