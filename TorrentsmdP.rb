require "nokogiri"
require "open-uri"

#Accessing files previously saved by "Torrentsmd.rb" script
main_page = "Torrents-page-"
first_page = 0
last_page = 2

#Arrays to store info!!Waiting to recieve it!
comedies = Array.new
users = Array.new


(first_page..last_page).each do |page_number|
  page = Nokogiri::HTML(open(main_page + page_number.to_s + ".html"))

#Searching for some info we interested in
      comedy = page.css("div td[2]").each do |n|
          if n.content.include? "Comedy"
            comedies << n.content

          end
      end

#Spent a litle time to find how to skip the first row, that actualy was a table content header
      active_users = page.css("div tr:not(:first-of-type) td[10]").each do |name|
          users << name.content
      end

end

puts "List of comedies within last 300 uploads:"
#Just puts a list of torrents marked as comedies,ex:
#Bad Moms  [2016 / BDRip] [Comedy] [6.5/10] [EN]
puts comedies

#Needed a space between puts
3.times {puts " "}

puts "Most frequent users last 300 uploads:"
top = Hash.new(0)
users.each{|u| top[u] += 1}
top.each{|k, v| "#{k} uploaded #{v} times"}
#Creates a descending list of users : MoreUploads >>> LessUploads
puts top.sort_by{|k, v| -v}
