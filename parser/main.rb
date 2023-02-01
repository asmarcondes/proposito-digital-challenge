# frozen_string_literal: true

Line = Struct.new(:time, :event, :content)

LOG_FORMAT = /
(?<time>\d{1,2}:\d{2})        # Time
\s(?<event>[a-zA-Z]+(?=:))\W  # Event
\s(?<content>.*)              # Content
/x.freeze

current_game = 0
games = {}

def parse_line(line)
  line.match(LOG_FORMAT) { |m| Line.new(*m.captures) }
end

File.foreach('./parser/logs/games.log') do |line|
  register = parse_line(line)

  if register
    if register.event.eql?('InitGame')
      current_game += 1
      games["game_#{current_game}"] = {
        total_kills: 0,
        players: [],
        kills: Hash.new(0)
      }
    end

    if register.event.eql?('ClientUserinfoChanged')
      games["game_#{current_game}"][:players] |= [register.content[/(?<=\d\sn\\)(.+)(?=\\t\\0)/]]
    end

    if register.event.eql?('Kill')
      killer = register.content[/(?<=:\s)(?<killer>.+)(?=\skilled)/]
      killed = register.content[/(?<=killed\s)(.+)(?=\sby)/]

      games["game_#{current_game}"][:kills][killer] += 1 unless killer.eql?('<world>')
      games["game_#{current_game}"][:kills][killed] -= 1 if killer.eql?('world')

      games["game_#{current_game}"][:total_kills] += 1
    end
  end
end

puts games
