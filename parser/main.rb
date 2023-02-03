# frozen_string_literal: true

require_relative './modules/data'
require_relative './modules/report'

require_relative './models/log_parser'

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
