require "lita"

module Lita
  module Handlers
    class Redmine < Handler

      def self.default_config(config)
        config.url = nil
        config.type = :redmine # :chiliproject
        config.apikey = nil
      end

      route /redmine\s+(\d+)/, :redmine, help: { "redmine <issue #>" => "Displays issue url and subject" }

      def redmine(response)
        if Lita.config.handlers.redmine.url
          redmine_url = Lita.config.handlers.redmine.url.chomp("/")
        else
          raise "Redmine URL must be defined ('config.handlers.redmine.url')"
        end

        if Lita.config.handlers.redmine.apikey
          apikey = Lita.config.handlers.redmine.apikey
        else
          raise "Redmine API key must be defined ('config.handlers.redmine.apikey')"
        end

        case Lita.config.handlers.redmine.type
        when :redmine
          apikey_header = "X-Redmine-API-Key"
        when :chiliproject
          apikey_header = "X-ChiliProject-API-Key"
        else
          raise "Redmine type must be :redmine (default) or :chiliproject ('config.handlers.redmine.type')"
        end

        issue_url = "#{redmine_url}/issues/#{response.matches.flatten.first}"

        http_resp = http.get do |req|
          req.url "#{issue_url}.json"
          req.headers[apikey_header] = apikey
        end

        unless http_resp.status == 200
          raise "Failed to fetch #{issue_url} (#{http_resp.status})"
        end

        resp = MultiJson.load(http_resp.body)

        response.reply("#{issue_url} : #{resp["issue"]["subject"]}")
      rescue Exception => e
        response.reply("Error: #{e.message}")
      end
    end

    Lita.register_handler(Redmine)
  end
end
