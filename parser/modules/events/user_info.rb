# frozen_string_literal: true

# Processa o log de informações do jogador
module UserInfoEvent
  def self.process(line, game)
    player = line.content[Log::LOG_PATTERNS[:player]]
    game.add_player(player)

    game
  end
end
