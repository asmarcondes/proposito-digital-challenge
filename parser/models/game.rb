# frozen_string_literal: true

require 'set'
require 'json'
require_relative '../modules/log'

# Dados referentes à partida
class Game
  attr_reader :id, :players, :kills, :total_kills

  def initialize(id)
    @id = id
    @players = Set.new
    @kills = Hash.new(0)
    @total_kills = 0
  end

  def add_player(player)
    @players.add(player)
    @kills[player] = 0 unless @kills.key?(player)
  end

  def player_killed(killer, killed)
    world_killer = killer == Log::WORLD_ID

    @kills[killer] += 1 unless world_killer
    @kills[killed] -= 1 if world_killer
    @total_kills += 1
  end

  def to_hash
    {
      id: @id,
      players: @players.to_a,
      kills: @kills,
      total_kills: @total_kills
    }
  end
end
