require "spec_helper"

describe Lita::Handlers::Redmine, lita_handler: true do
  it { routes("get me redmine 12345, please").to(:redmine) }
  it { doesnt_route("redmine foo").to(:redmine) }
end
