# frozen_string_literal: true

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

current_game = ''
game_count = 0
games = {}

def parse_line(line)
  line.match(LOG_FORMAT) { |m| Line.new(*m.captures) }
end

File.foreach(LOG_PATH + log_file) do |line|
  register = parse_line(line)

  if register&.event == EVENT[:new_game]
    game_count += 1
    current_game = "#{GAME_PREFIX}#{game_count}"
    games[current_game] = {
      total_kills: 0,
      players: [],
      kills: Hash.new(0)
    }
  end

  games[current_game][:players] |= [register.content[PLAYER_FORMAT]] if register&.event == EVENT[:user_info]

  if register&.event == EVENT[:kill]
    killer = register.content[KILLER_FORMAT]
    killed = register.content[KILLED_FORMAT]

    games[current_game][:kills][killer] += 1 unless killer == WORLD_ID
    games[current_game][:kills][killed] -= 1 if killer == WORLD_ID

    games[current_game][:total_kills] += 1
  end
end

puts games
