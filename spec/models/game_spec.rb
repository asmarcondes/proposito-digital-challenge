# frozen_string_literal: true

require './parser/models/game'

RSpec.describe Game do
  subject(:game) { described_class.new(id) }

  let(:id) { 5 }
  let(:player) { 'Player A' }

  describe '.new' do
    context 'com atributos válidos' do
      it { is_expected.to be_a(described_class) }
    end
  end

  describe '#add_player' do
    context 'com player duplicado' do
      it 'não é válido' do
        game.add_player('Player A')
        game.add_player('Player A')

        expect(game.players.size).to eq(1)
      end

      context 'kills já adicionadas' do
        it 'não devem ser alteradas' do
          game.add_player(:player)

          3.times do
            game.player_killed(:player, 'B')
          end

          game.add_player(:player)

          expect(game.kills[:player]).to eq(3)
        end
      end
    end

    context 'player novo' do
      it 'não deve ter kills' do
        game.add_player('Player A')

        expect(game.kills['Player A']).to eq(0)
      end
    end
  end

  describe '#player_killed' do
    context 'player matou outro' do
      it 'player ganha 1 kill' do
        game.player_killed(:player, 'B')

        expect(game.kills[:player]).to eq(1)

        game.player_killed(:player, 'C')

        expect(game.kills[:player]).to eq(2)
      end
    end

    context 'player morreu pelo <world>' do
      it 'player perde 1 kill' do
        %w[B C D].each do |killed|
          game.player_killed(:player, killed)
        end

        game.player_killed('<world>', :player)

        expect(game.kills[:player]).to eq(2)
      end

      it 'não deve ter jogador <world> na lista de kills' do
        game.player_killed(:player, 'B')
        game.player_killed('<world>', :player)

        expect(game.kills.size).to eq(1)
        expect(game.kills['<world>']).to eq(0)
      end

      it 'kill do <world> soma no total de kills' do
        game.player_killed(:player, 'B')
        game.player_killed(:player, 'C')
        game.player_killed('<world>', :player)
        game.player_killed('<world>', :player)

        expect(game.total_kills).to eq(4)
      end
    end
  end

  describe '#to_hash' do
    it 'retorna o game como hash' do
      expect(game.to_hash).to be_a(Hash)
    end
  end
end
