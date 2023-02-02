# frozen_string_literal: true

require_relative './modules/log'
require_relative './modules/events/new_game'
require_relative './modules/events/user_info'
require_relative './modules/events/kill'

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
        games[game_id] = NewGameEvent.process
      },
      EVENT[:user_info] => lambda { |line|
        games[game_id] = UserInfoEvent.process(line, games[game_id])
      },
      EVENT[:kill] => lambda { |line|
        games[game_id] = KillEvent.process(line, games[game_id])
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
