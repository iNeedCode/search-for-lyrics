require 'rubygems'
require 'open-uri'
require 'nokogiri'

# get the title and album name of current iTunes track
album = `osascript -e'tell application "iTunes"' -e'get album of current track' -e'end tell'`.chop!.to_s
title = `osascript -e'tell application "iTunes"' -e'get name of current track' -e'end tell'`.chop!.to_s

# edit the title and album like the url pattern
if title.split.size > 1
  title = title.gsub(' ','-').downcase
end

if album.split.size > 1
  album = album.gsub(' ','-').downcase
else
  album.downcase!
end


url = "http://bollyrics.com/#{album}/#{title}-lyrics-movie-#{album}/"
#puts url
doc = Nokogiri::HTML(open(url))
#puts doc


# go thorugh the lyrics and fetch just lyrics
lyrics=""
hop_over_first_p_tag = 0
 doc.xpath("//div/p[not(@class='post-meta' or @class='must-log-in' or @class='post-date')]").each do |ly|
   #puts ly.has_attribute?('must-log-in')
   hop_over_first_p_tag += 1
   puts hop_over_first_p_tag
   next if hop_over_first_p_tag < 2
   
   #puts ly
   lyrics += ly
   lyrics += "\n\n"
 end
 
 puts lyrics