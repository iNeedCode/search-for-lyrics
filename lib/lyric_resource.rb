require 'support/text_helper'
require 'open-uri'
require 'nokogiri'
require 'text'

class LyricResource
  include TextHelper
  
  @@filepath = File.join(APP_ROOT, "searched_itunes_titles.txt")

  def self.create_file
    return true if file_usable?
    File.open(@@filepath, 'w') unless File.exists?(@@filepath)
    return file_usable?
  end
  
  def self.file_usable?
    return false unless @@filepath
    return false unless File.exists?(@@filepath)
    return false unless File.readable?(@@filepath)
    return false unless File.writable?(@@filepath)
    return true
  end

  def self.saved_titles
    titles = []
    title = ""
    if file_usable?
      file = File.new(@@filepath, 'r')
      file.each_line do |line|
        title = line.chomp!.split("\t")
        titles << title
      end
    end
    titles
  end
  
  def initialize(track)
    @track = track
    @notification={ :found=>false ,:subtitle => "#{@track[:title]} : #{@track[:album]}", :lyric => ""}
    if already_searched?
      @notification[:title] = "Bereits Erfolgreich gefunden!"
      @notification[:message] = "Für erneute Suche Datensatz aus Textfile löschen"
    else
      search_for_lyrics
      save_lyric_to_textfile if @notification[:found]
    end
  end
  
  def search_for_lyrics
    return true if search_under_bollywoodlyrics
    return true if search_under_paksmile    
    return false
  end
  
  def search_under_bollywoodlyrics
    @notification[:message] = "www.bollywoodlyrics.com"
    lyrics=""
    album=@track[:album].downcase
    album = album.gsub(' ','-') if album.split.size > 1
    
    url = "http://www.bollywoodlyrics.com/movie_name/#{album}"
    doc = open_link(url)
    return false unless doc
    
    #save all album titles
    album_titles={}
    doc.xpath('//p[@class="entry-title"]/a').each do |ly|
    		album_titles["#{ly.to_s.scan(/>([^"]*)<\/a>/)}"]= ly.to_s.scan(/href="([^"]*)"/)
    end
 
    find_title = find_album_title_on_page(album_titles)
    
    unless find_title==""
      doc = open_link(find_title.to_s)
        doc.xpath('//div[@class="entry-content"]/pre').each do |line|
          lyrics += line
        end
        
      # #############################        TODO         ###########################  
      # Tadap Tadap Example  
      # unless lyrics.size > 50 
      #  doc.xpath('//div[@class="entry-content"]/p').each do |line|
      #    lyrics += "#{line}\n"
      #  end
      #end
    end
    #lyrics = lyrics.delete(lyrics.to_s.scan(/<p class(.*)/))
    puts lyrics
    
    set_notification(lyrics)
    return @notification[:found]
  end
  
  def search_under_paksmile
    @notification[:message] = "www.paksmile.com"
    lyrics=""
    url = "http://www.bollywoodlyrics.com/movie_name/#{@track[:album]}"
    doc = open_link(url)
    return false unless doc

    #save all album titles
    album_titles={}
    doc.xpath('//p[@class="entry-title"]/a').each do |ly|
    		album_titles["#{ly.to_s.scan(/>([^"]*)<\/a>/)}"]= ly.to_s.scan(/href="([^"]*)"/)
    end
  
    find_title = find_album_title_on_page(album_titles)
    
    unless find_title==""
      doc = open_link(find_title.to_s)
        doc.xpath('//div[@class="entry-content"]/pre').each do |line|
          lyrics += line
        end
    end
    
    set_notification(lyrics)
    return @notification[:found]
  end
  
  def notification
    return @notification
  end
  
  def already_searched?
    unless LyricResource.file_usable?
      LyricResource.create_file
    end
    find_title_in_file
  end

  def find_title_in_file
    titles = LyricResource.saved_titles
    found = nil
    found = titles.select do |title|
      title[0].include?(@track[:title]) &&
      title[1].include?(@track[:album])
    end
    return true unless found.empty? 
    return false
  end
  
  def save_lyric_to_textfile
    return false unless LyricResource.file_usable?
    File.open(@@filepath, 'a') do |file|
      file.puts "#{[@track[:title],@track[:album]].join("\t")}\n"
    end
    return true
  end
  
  def set_notification(lyrics)
    if lyrics.size > 50
      @notification[:lyric] = lyrics
      @notification[:found] = true
      @notification[:title] = "Erfolgreich"
    end
  end
  
  def open_link(url)
    begin
      doc = Nokogiri::HTML(open(url))
    rescue Exception => ex
      puts "Error: #{ex}"
      @notification[:message] = "Fehler #{ex}"
      @notification[:title] = "Fehler"
      return false
    end
    doc
  end
  
end