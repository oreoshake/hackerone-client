module HackerOne
  module Client
    module ResourceHelper
      def parse_response(response)
        HackerOne::Client::Api.parse_response(response)
      end

      def make_post_request(url, request_body:)
        response = HackerOne::Client::Api.hackerone_api_connection.post do |req|
          req.headers['Content-Type'] = 'application/json'
          req.url url
          req.body = { data: request_body }.to_json
        end

        parse_response(response)
      end

      def make_get_request(url, params: {})
        response = HackerOne::Client::Api.hackerone_api_connection.get do |req|
          req.headers['Content-Type'] = 'application/json'
          req.url url
          req.params = params
        end

        parse_response(response)
      end

      private

      def api_connection
        HackerOne::Client::Api.hackerone_api_connection
      end
    end
  end
end
