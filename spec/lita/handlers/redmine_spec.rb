require "spec_helper"

describe Lita::Handlers::Redmine, lita_handler: true do

  before do
    Lita.configure do |config|
      config.handlers.redmine.url = "https://redmine.example.com"
      config.handlers.redmine.type = :chiliproject
      config.handlers.redmine.apikey = "0000000000000000000000000000000000000000"
    end
  end

  it { routes("get me redmine 12345, please").to(:issue) }
  it { doesnt_route("redmine foo").to(:issue) }

  describe "#issue" do
    let(:response) do
      response = double("Faraday::Response")
      allow(response).to receive(:status).and_return(200)
      response
    end

    describe "params" do
      it "replies with error if URL is not defined" do
        Lita.configure do |config|
          config.handlers.redmine.url = nil
        end

        send_command("redmine 42")
        expect(replies.last).to eq("Error: Redmine URL must be defined ('config.handlers.redmine.url')")
      end

      it "replies with error if API key is not defined" do
        Lita.configure do |config|
          config.handlers.redmine.apikey = nil
        end

        send_command("redmine 42")
        expect(replies.last).to eq("Error: Redmine API key must be defined ('config.handlers.redmine.apikey')")
      end

      it "replies with error if Type is not defined" do
        Lita.configure do |config|
          config.handlers.redmine.type = nil
        end

        send_command("redmine 42")
        expect(replies.last).to eq("Error: Redmine type must be :redmine (default) or :chiliproject ('config.handlers.redmine.type')")
      end
    end

    before do
      allow_any_instance_of(Faraday::Connection).to receive(:get).and_return(response)
    end

    it "replies with the title and URL for the issue" do
      allow(response).to receive(:body).and_return(<<-JSON.chomp
{
  "issue": {
    "author": {
      "name": "The Greybeards",
      "id": 70
    },
    "subject": "Destroy Alduin",
    "priority": {
      "name": "High",
      "id": 4
    },
    "updated_on": "2013-10-31T17:07:20+01:00",
    "done_ratio": 0,
    "start_date": "2012-11-22",
    "status": {
      "name": "Assigned",
      "id": 2
    },
    "project": {
      "name": "Skyrim",
      "id": 1
    },
    "description": "",
    "assigned_to": {
      "name": "Dovahkin",
      "id": 99
    },
    "tracker": {
      "name": "Bug",
      "id": 2
    },
    "created_on": "2012-11-22T14:52:33+01:00",
    "id": 42
  }
}
JSON
      )

      send_command("redmine 42")

      expect(replies.last).to eq("https://redmine.example.com/issues/42 : Destroy Alduin")
    end

    it "replies that the issue doesn't exist" do
      allow(response).to receive(:status).and_return(404)

      send_command("redmine 42")

      expect(replies.last).to eq("Issue #42 does not exist")
    end

    it "replies with an excception message" do
      allow(response).to receive(:status).and_return(500)

      send_command("redmine 42")

      expect(replies.last).to match(/^Error: /)
    end
  end
end
