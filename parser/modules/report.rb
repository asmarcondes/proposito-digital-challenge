# frozen_string_literal: true

# Módulo para "imprimir" o relatório dos games no terminal
module Report
  def self.generate(games)
    ranking = Hash.new(0)

    games.each_with_index do |value, index|
      puts "\n----- Game ##{index + 1} -----"
      puts "\nPlayers:"

      game = value.last
      sorted_players = game.players.sort

      sorted_players.each do |player|
        puts "- #{player}"
      end

      puts "\nKills:"
      puts "- (#{game.total_kills})\tTOTAL KILLS"

      sorted_kills = game.kills.sort_by { |_a, b| -b }

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
  end
end
