require 'rubygems'
require 'open-uri'
require 'nokogiri'


album = `osascript -e'tell application "iTunes"' -e'get album of current track' -e'end tell'`.chop!.to_s
title = `osascript -e'tell application "iTunes"' -e'get name of current track' -e'end tell'`.chop!.to_s

if title.split.size > 1
  title = title.gsub!(' ','-')
else
  title.downcase!
end

if album.split.size > 1
  album = album.gsub!(' ','-').downcase!
else
  album.downcase!
end


# doc = Nokogiri::HTML(open('http://www.paksmile.com/lyrics/murder-2/Aye-Khuda.asp'))
url = "http://www.paksmile.com/lyrics/#{album}/#{title}.asp"
doc = Nokogiri::HTML(open(url))

 lyrics=""
 doc.xpath('//td[@bgcolor="F2FCFF"]/p').each do |ly|
   lyrics += ly
   lyrics += "\n\n"
 end


if lyrics==""
  puts `terminal-notifier -message "Es wurde keine lyrics gefunden für #{title} vom Album #{album}" -title "Fehlgeschlagen"`
else 
  puts `osascript -e'tell application "iTunes"' -e'set lyrics of current track to "#{lyrics}"' -e'end tell'`
  puts `terminal-notifier -message "Lyric wurde Erfolgreich hinzugefügt für #{title} vom Album #{album}" -title "Erfolgreich"`
end

#puts lyrics