# frozen_string_literal: true

# Processa o log de morte de um jogador
module KillEvent
  def self.process(line, game)
    killer = line.content[Log::LOG_PATTERNS[:killer]]
    killed = line.content[Log::LOG_PATTERNS[:killed]]

    game[:kills][killer] += 1 unless killer == Log::WORLD_ID
    game[:kills][killed] -= 1 if killer == Log::WORLD_ID

    game[:total_kills] += 1

    game
  end
end
