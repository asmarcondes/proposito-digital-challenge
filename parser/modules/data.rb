# frozen_string_literal: true

require 'json'

# Módulo para ler/salvar os games em um arquivo JSON,
# para simular persistência em BD
module Data
  FILE_PATH = 'db/development.json'

  def self.save(hash)
    parsed_hash = parse_hash(hash)

    list = parsed_hash.map do |_key, value|
      value.to_hash
    end

    data = to_json({ games: list })

    File.open(FILE_PATH, 'wb') { |file| file.puts(data) }
  end

  def self.load
    file = File.read(FILE_PATH)
    JSON.parse(file)
  end

  # Converte os objetos dentro um Hash do tipo Set para Array
  # para posterior conversão em JSON
  def self.parse_hash(object)
    case object
    when Hash
      object.each do |key, value|
        object[key] = parse_hash(value)
      end
    when Set
      object.to_a
    else
      object
    end
  end

  def self.to_json(hash)
    JSON.pretty_generate(hash)
  end
end
