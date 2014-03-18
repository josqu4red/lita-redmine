require "lita"

module Lita
  module Handlers
    class Redmine < Handler

      def self.default_config(config)
        config.url = nil
        config.type = :redmine # :chiliproject
        config.apikey = nil
      end

      route /redmine\s+(\d+)/, :issue, help: { "redmine <issue #>" => "Displays issue url and subject" }

      def issue(response)
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

        issue_id = response.matches.flatten.first
        issue_url = URI.parse("#{redmine_url}/issues/#{issue_id}")
        issue_json_url = "#{issue_url}.json"

        http_resp = http.get(issue_json_url, {}, { apikey_header => apikey })

        case http_resp.status
        when 200
          resp = MultiJson.load(http_resp.body)
          message = "#{issue_url} : #{resp["issue"]["subject"]}"
        when 404
          message = "Issue ##{issue_id} does not exist"
        else
          raise "Failed to fetch #{issue_json_url} (#{http_resp.status})"
        end

        response.reply(message)
      rescue Exception => e
        response.reply("Error: #{e.message}")
      end
    end

    Lita.register_handler(Redmine)
  end
end
