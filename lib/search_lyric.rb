require 'rubygems'
require 'terminal-notifier'
require 'lyric_resource'

class SearchLyric
  
  def initialize()
    @track = current_itunes_track
    #check if already searched in archiv
    #perform_search(@track)
    perform_search
  end
  
  def current_itunes_track
    {:title=>"Titel", :album=>"Album"}
  end
  
  def perform_search
    rslt = LyricResource.new(@track)
    notification_center(rslt.notification)
  end
  
  def add_lyric_to_itunes(lyric)
    # applescript
  end
  
  def notification_center(nofication_option={})
    message = nofication_option.delete(:message) || ''
    TerminalNotifier.notify(message, nofication_option)
  end
  
end