# frozen_string_literal: true

# Processa o log de morte de um jogador
module KillEvent
  def self.process(line, game)
    content = line.content
    killer = content[Log::LOG_PATTERNS[:killer]]
    killed = content[Log::LOG_PATTERNS[:killed]]

    game.player_killed(killer, killed)

    game
  end
end
