require 'rubygems'
require 'open-uri'
require 'nokogiri'
require 'terminal-notifier'
require 'text'


album = `osascript -e'tell application "iTunes"' -e'get album of current track' -e'end tell'`.chop!.to_s
title = `osascript -e'tell application "iTunes"' -e'get name of current track' -e'end tell'`.chop!.to_s

if title.split.size > 1
  title = title.gsub!(' ','-')
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
   	title = `osascript -e'tell application "iTunes"' -e'get name of current track' -e'end tell'`.chop!.to_s
   	url = "http://www.paksmile.com/lyrics/#{album}/"
   	doc = Nokogiri::HTML(open(url))

  	album_titles={}
  	doc.xpath('//table[@bgcolor="#F2FCFF"]//strong/a').each do |ly|
    		album_titles["#{ly.to_s.scan(/>([^"]*)<\/a>/)}"]= ly.to_s.scan(/href="([^"]*)"/)
  	end


    best_match=0
    link_to_best_hit=""
  	white = Text::WhiteSimilarity.new
  	album_titles.each do |k,v|
      if white.similarity(title, k) > best_match
        link_to_best_hit = v
      end
  	end
    puts link_to_best_hit
    puts album
    
    
    # dirty solution
   url = "http://www.paksmile.com/lyrics/#{album}/#{link_to_best_hit.to_s}"
   puts url
    doc = Nokogiri::HTML(open(url))
 
     lyrics=""
     doc.xpath('//td[@bgcolor="F2FCFF"]/p').each do |ly|
       lyrics += ly
       lyrics += "\n\n"
     end
    #end dirty solution

    puts lyrics
    
 end
 


if lyrics==""
  TerminalNotifier.notify("Album: #{album.gsub('-',' ').capitalize}", :title => 'Fehlgeschlagen', :subtitle => "#{title.gsub('-',' ')}")
else 
  puts `osascript -e'tell application "iTunes"' -e'set lyrics of current track to "#{lyrics}"' -e'end tell'`
  TerminalNotifier.notify("Album: #{album.gsub('-',' ').capitalize}", :title => 'Erfolreich', :subtitle => "#{title.gsub('-',' ')}")
  
end