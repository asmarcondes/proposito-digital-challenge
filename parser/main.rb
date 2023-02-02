# frozen_string_literal: true

require 'set'
require_relative 'log_parser'

log_file = 'games.log'

parser = LogParser.new
games = parser.process(log_file)

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
