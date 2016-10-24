require "nokogiri"
require "open-uri"

PAGE_URL = "https://www.saltedge.com/pages/our_team"
page = Nokogiri::HTML(open(PAGE_URL))

#Store each member description in an array
review = []
  reviews = page.css('div.team-list p').each do |rev|
    review << rev.content
  end
#Store all members in an array
name = []
  members = page.css('div.team-list strong').each do |member|
    name << member.content
  end
#Merge each member with his own short personality review in a hash
our_team = Hash.new
  name.zip(review).each do |name, review|
    our_team[name] = review
  end
#Writing obtained info in a file, each name starts from a new line
File.open("saltedge-team.txt", "w") do |f|
  f.puts(our_team.map{|k, v| "#{k} => #{v}"})
end
