# frozen_string_literal: true

# Estrutura para armazenar dados chaves de
# cada linha do log (tempo, evento e conteúdo)
Line = Struct.new(:time, :event, :content)

# Módulo com patterns/constantes referentes ao log
module Log
  LOG_PATTERNS = {
    log: /
      (?<time>\d{1,2}:\d{2})        # Time
      \s(?<event>[a-zA-Z]+(?=:))\W  # Event
      \s(?<content>.*)              # Content
    /x,
    killer: /(?<=:\s)(?<killer>.+)(?=\skilled)/,
    killed: /(?<=killed\s)(.+)(?=\sby)/,
    player: /(?<=\d\sn\\)(.+)(?=\\t\\\d)/
  }.freeze

  EVENT = {
    new_game: 'InitGame',
    user_info: 'ClientUserinfoChanged',
    kill: 'Kill'
  }.freeze

  WORLD_ID = '<world>'
  GAME_PREFIX = 'game_'
  LOG_PATH = './parser/logs/'
end
