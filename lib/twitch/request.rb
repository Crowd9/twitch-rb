module Twitch
  module Request
    def build_query_string(options)
      query = "?"
      options.each do |key, value|
        query += "#{key}=#{value.to_s.gsub(" ", "+")}&"
      end
      query = query[0...-1]
    end

    def get(url)
      @adapter.get(url, :headers => {
        'Client-ID' => @client_id,
        'Authorization' => "Bearer #{@access_token}",
        'Accept' => 'application/json'
      })
    end

    def post(url, data)
      @adapter.post(url, :body => data, :headers => {
        'Client-ID' => @client_id,
        'Authorization' => "Bearer #{@access_token}",
        'Accept' => 'application/json'
      })
    end

    def put(url, data={})
      @adapter.put(url, :body => data, :headers => {
        'Content-Type' => 'application/json',
        'Client-ID' => @client_id,
        'Authorization' => "Bearer #{@access_token}",
        'Accept' => 'application/json'
      })
    end

    def delete(url)
      @adapter.delete(url, :headers => {
        'Client-ID' => @client_id,
        'Authorization' => "Bearer #{@access_token}",
        'Accept' => 'application/json'
      })
    end
  end
end
