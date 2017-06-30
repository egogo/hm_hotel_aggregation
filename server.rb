require 'sinatra'
require 'json'
require_relative 'aggregation_service'

get '/hotels/search' do
  content_type :json

  { results: AggregationService.aggregate }.to_json
end
