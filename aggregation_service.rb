require 'net/http'
require 'json'

class AggregationService
  PROVIDERS = %w(Expedia Orbitz Priceline Travelocity Hilton).freeze
  BASE_URL = 'http://localhost:9000/scrapers'

  class << self

    def aggregate(providers = PROVIDERS)
      results, mutex = [], Mutex.new
      # TODO: limit number or threads to account for potentially huge list of providers?
      providers.map do |name|
        Thread.new do
          result = fetch_provider(name)
          mutex.synchronize { results << result }
        end
      end.each(&:join)

      merge(results)
    end

    private

    def fetch_provider(name)
      response = Net::HTTP.get(URI(BASE_URL + '/' + name))
      JSON.parse(response)['results']
    rescue Exception => e
      puts "Error while fetching for #{name}: #{e.message}"
      []
    end

    def merge(arr)
      current_head = arr.map(&:shift)
      results = []
      while current_head.any? {|i| !i.nil? }
        max_elem = current_head.max {|a,b| ecstasy_value_for(a) <=> ecstasy_value_for(b) }
        idx = current_head.index(max_elem)
        results << max_elem
        current_head[idx] = arr[idx].shift
      end
      results
    end

    def ecstasy_value_for(o)
      o ? (o['ecstasy'] || 0) : 0
    end

  end
end