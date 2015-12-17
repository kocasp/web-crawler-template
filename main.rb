require 'rubygems'
require 'nokogiri'
require 'open-uri'

url = "http://www.futbol24.com/national/Qatar/Qatar-Stars-League/2011-2012/"
doc = Nokogiri::HTML(open(url))
puts doc.at_css("title").text

@country = "Qatar"

p doc.at('a:contains("Qatar")')
p ""
p doc.at('a:contains("Qatar")').parent.children.length

