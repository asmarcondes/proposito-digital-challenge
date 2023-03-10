# frozen_string_literal: true

require 'sinatra'
require_relative '../parser/modules/data'

get '/games/:id' do
  id = params[:id].to_i

  result = Data.load
  games = result['games']
  game_founded = games.find { |game| game['id'] == id }

  if game_founded
    content_type(:json)
    game_founded.to_json
  else
    status(404)
  end
end

not_found do
  error = { error: 'Resource not found' }
  error.to_json
end
