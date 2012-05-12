# coding: utf-8

desc "Fetch product prices"
task :fetch => :environment do
  require 'nokogiri'
  require 'open-uri'

  Character.all.each do |char|
    char.fetch_armory(true)
  end
end
