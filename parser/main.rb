# frozen_string_literal: true

require_relative 'log_parser'
require_relative './modules/data'
require_relative './modules/report'

# Módulo que serve de ponto de partida da aplicação
module Main
  LOG_FILE = 'games.log'

  def self.run
    parser = LogParser.new
    games = parser.process(LOG_FILE)

    Data.save(games)
    Report.generate(games)
  end
end

Main.run
