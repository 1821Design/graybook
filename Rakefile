# -*- ruby -*-

require 'rubygems'
$LOAD_PATH.unshift 'lib'
require 'graybook'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |s|
    s.name        = "graybook"
    s.summary     = "It does things. Like import contacts from EVERYWHERE. (Some sites may be excluded)"
    s.email       = "kojul@kojul.com"
    s.homepage    = "http://github.com/kojul/gray"
    s.description = "Graybook is used to import email contact lists from popular webmail sites. Currently supported are AOL/AIM, Yahoo, Hotmail/Live/MSN, and Google Mail (although not Google Apps Mail yet)."
    s.authors     = ["kojul", "Contentfree"]
    s.add_dependency('hpricot', '>= 0.8.4')
    s.add_dependency('mechanize', '>= 1.0.0')
    s.add_dependency('fastercsv', '>= 1.2.0')
  end
rescue LoadError
  puts "Jeweler not available. Install it with: sudo gem install technicalpickles-jeweler -s http://gems.github.com"
end
