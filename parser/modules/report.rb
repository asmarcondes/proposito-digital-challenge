# frozen_string_literal: true

# Módulo para "imprimir" o relatório dos games no terminal
module Report
  def self.generate(games)
    ranking = Hash.new(0)

    games.each_with_index do |value, index|
      game = value.last
      kills = game.kills

      ranking = update_ranking(ranking, kills)

      print_game_header(index)
      print_players(game.players)
      print_kill_header(game.total_kills)
      print_kills(kills)
    end

    print_ranking(ranking)
  end

  def self.update_ranking(ranking, kills)
    kills.each do |kill|
      player, value = kill

      ranking[player] += value
    end

    ranking
  end

  def self.print_game_header(index)
    puts "\n----- Game ##{index + 1} -----"
    puts "\nPlayers:"
  end

  def self.print_kill_header(total_kills)
    puts "\nKills:"
    puts "- (#{total_kills})\tTOTAL KILLS"
  end

  def self.print_players(players)
    sorted_players = players.sort

    sorted_players.each do |player|
      puts "- #{player}"
    end
  end

  def self.print_kills(kills)
    sorted_kills = kills.sort_by { |_a, value| -value }

    sorted_kills.each do |kill|
      player, value = kill

      puts "- (#{value})\t#{player}"
    end
  end

  def self.print_ranking(ranking)
    current_position = 0
    last_kills = 0

    puts "\n----- KILLS RANKING -----\n\n"

    sorted_ranking = ranking.sort_by { |_a, value| -value }

    sorted_ranking.each do |kill|
      player, value = kill

      current_position += 1 unless value == last_kills
      last_kills = value

      puts "#{current_position}º #{player} (#{value})"
    end
  end
end
