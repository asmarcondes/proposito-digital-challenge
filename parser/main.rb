# frozen_string_literal: true

require 'set'

# Módulo com patterns/constantes referentes ao log
module Log
  LOG_PATTERNS = {
    log: /
      (?<time>\d{1,2}:\d{2})        # Time
      \s(?<event>[a-zA-Z]+(?=:))\W  # Event
      \s(?<content>.*)              # Content
    /x,
    killer: /(?<=:\s)(?<killer>.+)(?=\skilled)/,
    killed: /(?<=killed\s)(.+)(?=\sby)/,
    player: /(?<=\d\sn\\)(.+)(?=\\t\\\d)/
  }.freeze

  EVENT = {
    new_game: 'InitGame',
    user_info: 'ClientUserinfoChanged',
    kill: 'Kill'
  }.freeze

  LOG_PATH = './parser/logs/'

  def self.get_file_path(file_name)
    LOG_PATH + file_name
  end
end

Line = Struct.new(:time, :event, :content)

log_file = 'games.log'

WORLD_ID = '<world>'
GAME_PREFIX = 'game_'

game_id = ''
game_count = 0
games = {}

def parse_line(line)
  line.match(Log::LOG_PATTERNS[:log]) { |m| Line.new(*m.captures) }
end

File.foreach(Log.get_file_path(log_file)) do |line|
  register = parse_line(line)

  if register&.event == Log::EVENT[:new_game]
    game_count += 1
    game_id = "#{GAME_PREFIX}#{game_count}"

    games[game_id] = {
      total_kills: 0,
      players: Set.new,
      kills: Hash.new(0)
    }
  end

  if register&.event == Log::EVENT[:user_info]
    player = register.content[Log::LOG_PATTERNS[:player]]
    games[game_id][:players].add(player)
    games[game_id][:kills][player] = 0 unless games[game_id][:kills].key?(player)
  end

  if register&.event == Log::EVENT[:kill]
    killer = register.content[Log::LOG_PATTERNS[:killer]]
    killed = register.content[Log::LOG_PATTERNS[:killed]]

    games[game_id][:kills][killer] += 1 unless killer == WORLD_ID
    games[game_id][:kills][killed] -= 1 if killer == WORLD_ID

    games[game_id][:total_kills] += 1
  end
end

ranking = Hash.new(0)

games.each_with_index do |value, index|
  puts "\n----- Game ##{index + 1} -----"
  puts "\nPlayers:"

  data = value.last
  sorted_players = data[:players].sort

  sorted_players.each do |player|
    puts "- #{player}"
  end

  puts "\nKills:"
  puts "- (#{data[:total_kills]})\tTOTAL KILLS"

  sorted_kills = data[:kills].sort_by { |_a, b| -b }

  sorted_kills.each do |kill|
    ranking[kill.first] += kill.last
    puts "- (#{kill.last})\t#{kill.first}"
  end
end

puts "\n----- KILLS RANKING -----\n\n"

current_position = 0
last_kills = 0

sorted_ranking = ranking.sort_by { |_a, b| -b }

sorted_ranking.each_with_index do |kill, _index|
  current_position += 1 unless kill.last == last_kills
  last_kills = kill.last

  puts "#{current_position}º #{kill.first} (#{kill.last})"
end
