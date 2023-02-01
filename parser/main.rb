# frozen_string_literal: true

Line = Struct.new(:time, :event, :content)

LOG_PATH = './parser/logs/games.log'

LOG_FORMAT = /
  (?<time>\d{1,2}:\d{2})        # Time
  \s(?<event>[a-zA-Z]+(?=:))\W  # Event
  \s(?<content>.*)              # Content
/x.freeze

KILLER_FORMAT = /(?<=:\s)(?<killer>.+)(?=\skilled)/.freeze
KILLED_FORMAT = /(?<=killed\s)(.+)(?=\sby)/.freeze
PLAYER_FORMAT = /(?<=\d\sn\\)(.+)(?=\\t\\0)/.freeze

WORLD_NICK = '<world>'
GAME_PREFIX = 'game_'

EVENT = {
  new_game: 'InitGame',
  user_info: 'ClientUserinfoChanged',
  kill: 'Kill'
}.freeze

current_game = 0
games = {}

def parse_line(line)
  line.match(LOG_FORMAT) { |m| Line.new(*m.captures) }
end

File.foreach(LOG_PATH) do |line|
  register = parse_line(line)

  if register
    if register.event == EVENT[:new_game]
      current_game += 1
      games["#{GAME_PREFIX}#{current_game}"] = {
        total_kills: 0,
        players: [],
        kills: Hash.new(0)
      }
    end

    if register.event == EVENT[:user_info]
      games["#{GAME_PREFIX}#{current_game}"][:players] |= [register.content[PLAYER_FORMAT]]
    end

    if register.event == EVENT[:kill]
      killer = register.content[KILLER_FORMAT]
      killed = register.content[KILLED_FORMAT]

      games["#{GAME_PREFIX}#{current_game}"][:kills][killer] += 1 unless killer == WORLD_NICK
      games["#{GAME_PREFIX}#{current_game}"][:kills][killed] -= 1 if killer == WORLD_NICK

      games["#{GAME_PREFIX}#{current_game}"][:total_kills] += 1
    end
  end
end

puts games
