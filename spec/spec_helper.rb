require 'rubygems'
require 'bundler/setup'
require 'cog'
require 'rspec/cog'
require 'webrick'
require 'json'

RSpec.configure do |config|
  config.include Cog::RSpec::Setup
end
