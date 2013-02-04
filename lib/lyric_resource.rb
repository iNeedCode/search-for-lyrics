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
  
  def notification
    return @notification
  end
  
  def initialize(track)
    @track = track
    @notification={:title => "Bereits vorher schon gesucht!", :subtitle => "#{@track[:title]} : #{@track[:album]}" }
    if already_searched?
      @notification[:message] = "Datensatz aus Textfile löschen"
    else
      puts "WEBSEITEN SUCHEN ......."
      save_lyric
    end
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
  
  def save_lyric
    return false unless LyricResource.file_usable?
    File.open(@@filepath, 'a') do |file|
      file.puts "#{[@track[:title],@track[:album]].join("\t")}\n"
    end
    return true
  end
  
end