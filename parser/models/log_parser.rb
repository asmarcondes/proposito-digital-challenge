# frozen_string_literal: true

require_relative '../modules/log'
require_relative '../modules/events/new_game'
require_relative '../modules/events/user_info'
require_relative '../modules/events/kill'

# Classe responsável por extrair os dados do arquivo de log
class LogParser
  include Log

  attr_reader :games, :current_game_index, :current_game

  def initialize
    @games = {}
    @current_game_index = 0
    @current_game = {}
  end

  def parse_line(line)
    line.match(LOG_PATTERNS[:log]) { |m| Line.new(*m.captures) }
  end

  def process(filename)
    File.foreach(get_file_path(filename)) do |line|
      register = parse_line(line)
      event_name = register&.event
      events_actions[event_name]&.call(register)
    end

    @games
  end

  private

  def events_actions
    new_game = lambda { |_line|
      increment_game_count
      @current_game = update_game(NewGameEvent.process(@current_game_index))
    }

    user_info = lambda { |line|
      update_game(UserInfoEvent.process(line, @current_game))
    }

    kill = lambda { |line|
      update_game(KillEvent.process(line, @current_game))
    }

    {
      EVENT[:new_game] => new_game,
      EVENT[:user_info] => user_info,
      EVENT[:kill] => kill
    }
  end

  def increment_game_count
    @current_game_index += 1
  end

  def update_game(game)
    id = "#{GAME_PREFIX}#{@current_game_index}"

    @games[id] = game
    @games[id]
  end
end
