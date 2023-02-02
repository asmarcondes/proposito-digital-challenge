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

    events = {
      EVENT[:new_game] => lambda { |_line|
        game_count += 1
        game_id = "#{GAME_PREFIX}#{game_count}"

        games[game_id] = {
          total_kills: 0,
          players: Set.new,
          kills: Hash.new(0)
        }
      },
      EVENT[:user_info] => lambda { |line|
        player = line.content[LOG_PATTERNS[:player]]
        games[game_id][:players].add(player)
        games[game_id][:kills][player] = 0 unless games[game_id][:kills].key?(player)
      },
      EVENT[:kill] => lambda { |line|
        killer = line.content[LOG_PATTERNS[:killer]]
        killed = line.content[LOG_PATTERNS[:killed]]

        games[game_id][:kills][killer] += 1 unless killer == WORLD_ID
        games[game_id][:kills][killed] -= 1 if killer == WORLD_ID

        games[game_id][:total_kills] += 1
      }
    }

    File.foreach(get_file_path(filename)) do |line|
      register = parse_line(line)

      event_name = register&.event
      events[event_name]&.call(register)
    end

    games
  end
end
