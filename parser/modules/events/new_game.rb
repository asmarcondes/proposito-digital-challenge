# frozen_string_literal: true

# Processa o log de novo jogo
module NewGameEvent
  def self.process
    {
      total_kills: 0,
      players: Set.new,
      kills: Hash.new(0)
    }
  end
end
