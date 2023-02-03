# frozen_string_literal: true

require 'set'

require_relative '../../models/game'

# Processa o log de novo jogo
module NewGameEvent
  def self.process(game_id)
    Game.new(game_id)
  end
end
