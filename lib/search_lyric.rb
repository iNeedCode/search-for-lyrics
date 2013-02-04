require 'rubygems'
require 'terminal-notifier'
require 'lyric_resource'

class SearchLyric
  
  def initialize()
    @track = current_itunes_track
    perform_search
  end
  
  def current_itunes_track
    track={}
    track[:album]=`osascript -e'tell application "iTunes"' -e'get album of current track' -e'end tell'`.chop!.to_s
    track[:title]=`osascript -e'tell application "iTunes"' -e'get name of current track' -e'end tell'`.chop!.to_s
    track
  end
  
  def perform_search
    rslt = LyricResource.new(@track).notification
    if rslt[:found]
      add_lyric_to_itunes(rslt[:lyric])
    end
    notification_center(rslt)
  end
  
  def add_lyric_to_itunes(lyric)
    lyric.to_s.gsub!("'", ' ')
    puts `osascript -e'tell application "iTunes"' -e'set lyrics of current track to "#{lyric}"' -e'end tell'`
  end
  
  def notification_center(nofication_option={})
    message = nofication_option.delete(:message) || ''
    TerminalNotifier.notify(message, nofication_option)
  end
  
end