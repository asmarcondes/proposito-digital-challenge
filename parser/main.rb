# frozen_string_literal: true

require 'set'

Line = Struct.new(:time, :event, :content)

LOG_PATH = './parser/logs/'
log_file = 'games.log'

LOG_FORMAT = /
  (?<time>\d{1,2}:\d{2})        # Time
  \s(?<event>[a-zA-Z]+(?=:))\W  # Event
  \s(?<content>.*)              # Content
/x.freeze

KILLER_FORMAT = /(?<=:\s)(?<killer>.+)(?=\skilled)/.freeze
KILLED_FORMAT = /(?<=killed\s)(.+)(?=\sby)/.freeze
PLAYER_FORMAT = /(?<=\d\sn\\)(.+)(?=\\t\\0)/.freeze

WORLD_ID = '<world>'
GAME_PREFIX = 'game_'

EVENT = {
  new_game: 'InitGame',
  user_info: 'ClientUserinfoChanged',
  kill: 'Kill'
}.freeze

game_id = ''
game_count = 0
games = {}

def parse_line(line)
  line.match(LOG_FORMAT) { |m| Line.new(*m.captures) }
end

File.foreach(LOG_PATH + log_file) do |line|
  register = parse_line(line)

  if register&.event == EVENT[:new_game]
    game_count += 1
    game_id = "#{GAME_PREFIX}#{game_count}"

    games[game_id] = {
      total_kills: 0,
      players: Set.new,
      kills: Hash.new(0)
    }
  end

  player = register.content[PLAYER_FORMAT] if register&.event == EVENT[:user_info]

  if register&.event == EVENT[:kill]
    killer = register.content[KILLER_FORMAT]
    killed = register.content[KILLED_FORMAT]

    games[game_id][:kills][killer] += 1 unless killer == WORLD_ID
    games[game_id][:kills][killed] -= 1 if killer == WORLD_ID

    games[game_id][:total_kills] += 1
  end
end

puts games
