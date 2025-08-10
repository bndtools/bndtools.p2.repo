# Simple Ruby webserver for the 'site' folder
# Usage: ruby server.rb
require 'webrick'

root = File.expand_path(File.dirname(__FILE__) + '/../site')
server = WEBrick::HTTPServer.new(:Port => 4001, :DocumentRoot => root)
trap('INT') { server.shutdown }
puts "Serving '#{root}' at http://localhost:4001/"
server.start
