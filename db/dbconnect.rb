require 'rubygems'
require 'active_record'
require 'yaml'

# Read the connection information from the database config file
dbconfig = YAML::load(File.open(File.expand_path(File.dirname(__FILE__) + '/config.yml')))

environment = ENV['environment'] || 'production'

# Connect to the database
ActiveRecord::Base.establish_connection(dbconfig[environment])