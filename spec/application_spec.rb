require_relative '../application.rb'
require 'rack/test'

set :environment, :test

def app
  Sinatra::Application
end

describe 'Autobuild Sinatra Application' do
  
  include Rack::Test::Methods
  
  it "should load the home page" do
    get '/'
    last_response.should be_ok
  end
  
  it "should fail gracefully when trying to access a non-routed page" do
    get '/about'
    browser = Rack::Test::Session.new(Rack::MockSession.new(app))
    browser.get '/about'
    browser.last_response.should be_ok
  end

end
