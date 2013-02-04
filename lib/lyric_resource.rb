require 'open-uri'
require 'nokogiri'
require 'text'

class LyricResource
  
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
    @notification={ :found=>false ,:subtitle => "#{@track[:title]} : #{@track[:album]}"}
    if already_searched?
      @notification[:title] = "Bereits gesucht!"
      @notification[:message] = "Für erneute Suche Datensatz aus Textfile löschen"
    else
      puts "WEBSEITEN SUCHEN ......."
      @notification[:message] = "www.XXXXXXXX.com"
      @notification[:title] = "Erfolgreich oder Fehlgeschlagen"
      @notification[:found] = false
      @notification[:lyric] = ""
      save_lyric_to_textfile
    end
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
  
end