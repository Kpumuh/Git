require "open-uri"
#Preparing links
PAGE_URL = "https://torrentsmd.com/browse.php?page="
first_page = 0
last_page = 2

#Looping needed quantity of pages
(first_page..last_page).each do |page_number|

  torrents = open(PAGE_URL + page_number.to_s).read

#Storing opened pages to my drive
  downloaded_filename = "Torrents-page-" + page_number.to_s + ".html"
  downloaded_file = open(downloaded_filename, "w")
    downloaded_file.write(torrents)
  downloaded_file.close
puts "Finished a page!"
end
#Will use stored pages for parsing in "TorrentsmdP.rb" file
