# frozen_string_literal: true

LOG_FORMAT = /
  (?<time>\d{1,2}:\d{2})        # Time
  \s(?<event>[a-zA-Z]+(?=:))\W  # Event
  \s(?<content>.*)              # Content
/x.freeze

File.foreach('./parser/logs/games.log') do |line|
  register = line.match(LOG_FORMAT)
  # puts register
  puts "#{register[:time]} / #{register[:event]} / #{register[:content]}" if register
end
