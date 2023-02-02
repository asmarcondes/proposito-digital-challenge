# frozen_string_literal: true

require_relative 'modules/log'

Line = Struct.new(:time, :event, :content)

# Classe responsável por extrair os dados do arquivo de log
class LogParser
  include Log

  def parse_line(line)
    line.match(LOG_PATTERNS[:log]) { |m| Line.new(*m.captures) }
  end

  def process(filename)
    games = {}
    game_id = ''
    game_count = 0

    File.foreach(get_file_path(filename)) do |line|
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

      if register&.event == EVENT[:user_info]
        player = register.content[LOG_PATTERNS[:player]]
        games[game_id][:players].add(player)
        games[game_id][:kills][player] = 0 unless games[game_id][:kills].key?(player)
      end

      if register&.event == EVENT[:kill]
        killer = register.content[LOG_PATTERNS[:killer]]
        killed = register.content[LOG_PATTERNS[:killed]]

        games[game_id][:kills][killer] += 1 unless killer == WORLD_ID
        games[game_id][:kills][killed] -= 1 if killer == WORLD_ID

        games[game_id][:total_kills] += 1
      end
    end

    games
  end
end
