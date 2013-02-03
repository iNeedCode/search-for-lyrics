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

    MIN_PERCENT_MATCH = 0.5
    best_match=0
    link_to_best_hit=""
  	white = Text::WhiteSimilarity.new
    similary=0
  	album_titles.each do |k,v|
      sim = white.similarity(title, k)
      if  sim > best_match && sim > MIN_PERCENT_MATCH
        puts "bessser als #{MIN_PERCENT_MATCH} #{v}"
        link_to_best_hit = v
      end
  	end
    
    
    unless link_to_best_hit==""
      # dirty solution
      url = "http://www.paksmile.com/lyrics/#{album}/#{link_to_best_hit.to_s}"
      doc = Nokogiri::HTML(open(url))
 
        
        doc.xpath('//td[@bgcolor="F2FCFF"]/p').each do |ly|
          lyrics += ly
          lyrics += "\n\n"
        end
       #end dirty solution
    end

 end
 
    lyrics.gsub!("'", ' ')

if lyrics==""
  TerminalNotifier.notify("Album: #{album.gsub('-',' ').capitalize}", :title => 'Fehlgeschlagen', :subtitle => "#{title.gsub('-',' ')}")
else 
  puts `osascript -e'tell application "iTunes"' -e'set lyrics of current track to "#{lyrics}"' -e'end tell'`
  TerminalNotifier.notify("Album: #{album.gsub('-',' ').capitalize}", :title => 'Erfolreich', :subtitle => "#{title.gsub('-',' ')}")
  
end



# TODO
# react on arguments ["", "current", "selection", "all"]
# 	class.current if ARGV[0]=='current' || ARGV.empty? 
#   class.selection if ARGV[0]=='selection'
#   class.all if ARGV[0]=='all'
#