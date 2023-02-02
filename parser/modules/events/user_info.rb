# frozen_string_literal: true

# Processa o log de informações do jogador
module UserInfoEvent
  def self.process(line, game)
    player = line.content[Log::LOG_PATTERNS[:player]]
    game[:players].add(player)
    game[:kills][player] = 0 unless game[:kills].key?(player)

    game
  end
end
