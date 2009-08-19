require 'rubygems'
require 'yaml'
require 'active_support'
require 'smqueue'
$:.unshift File.expand_path(File.dirname(__FILE__) + '/../lib')
require 'ipn'

puts "#{File.basename($0)} starting..."