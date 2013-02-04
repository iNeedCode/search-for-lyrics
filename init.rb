APP_ROOT = File.dirname(__FILE__)
# require File.join(APP_ROOT, 'lib', 'search_lyric')
$:.unshift(File.join(APP_ROOT, 'lib'))
require 'search_lyric'


SearchLyric.new