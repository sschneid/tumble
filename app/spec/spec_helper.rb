require 'rubygems'
require File.join(File.dirname(__FILE__), "../", 'tumble.rb')

require 'rack/test'
require 'ruby-debug'
require 'rspec'
require 'fakeweb'
require 'nokogiri'

#require File.join(File.dirname(__FILE__), '/spec_matchers.rb'

# set the test environment
set :environment, :test
set :run, false
set :raise_errors, true
set :logging, false
