require "nokogiri"
require "open-uri"

#Splited full page for more handly use later
base_page = "https://point.md"
page_plus = "/ru/novosti/"
first_page = 1
last_page = 100

links_to_filat = []
(first_page..last_page).each do |page_number|
  page = Nokogiri::HTML(open(base_page + page_plus + page_number.to_s + "/"))
  page.css('div a').each do |n|
#In search of link with some info about Filat
    if "#{n.text}\t#{n['href']}".include? "filat"
      links_to_filat << base_page + n['href']
    end
  end
end
#Writing all links found in txt
File.open("PointMD_links_to_filat.txt", "w") do |f|
  f.puts(links_to_filat.uniq.map {|k| "#{k}"})
end
