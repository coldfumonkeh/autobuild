require 'rubygems'
require 'bundler/setup'
require 'sinatra'
require 'rest_client'
require 'haml'
require File.join(File.dirname(__FILE__), 'environment')

configure do
  set :views, "#{File.dirname(__FILE__)}/views"
  DataMapper.finalize
end

configure :development do
  DataMapper.auto_upgrade!
    
  # very useful for debugging parameters sent via the console
  before do
    puts '[Params]'
    p params
  end
    
end

helpers do  
  include Rack::Utils  
  alias_method :h, :escape_html  
end

def get_or_post(path, opts={}, &block)
  get(path, opts, &block)
  post(path, opts, &block)
end

get_or_post '/' do
  haml  :index
end

get '/register' do

  @exampleClientID = '2d931510-d99f-494a-8c67-87feb05e1594'
  @clientExampleURL = SiteConfig.url_base + @exampleClientID + '/123456'
  haml  :register

end

post '/register' do

  @client = Clients.first_or_create(
            { 
              :username   =>  params[:username], 
              :password   =>  params[:password]
            },
            {
              :id         =>  SecureRandom.uuid,
              :username   =>  params[:username],
              :password   =>  params[:password],
              :created_at =>  Time.now,
              :updated_at =>  Time.now
            }
          )
    
  @clientExampleURL = SiteConfig.url_base + @client.id + '/123456'
            
  haml  :register

end

get_or_post '/:clientid/:appid' do

  @client = Clients.first(:id => params[:clientid])
  
  if @client
  
    pgURL = 'https://build.phonegap.com/apps/' + params[:appid] + '/push'
    private_resource = RestClient::Resource.new pgURL, @client.username, @client.password
    private_resource.get{ |response, request, result, &block|
    if [301, 302, 307].include? response.code
    response.follow_redirection(request, result, &block)
    end
    
    }
    
  else
  
    # May want to handle some output here for failed client ID
    
  end

end

get_or_post '/:user/:pass/:appid' do

        pgURL = 'https://build.phonegap.com/apps/' + params[:appid] + '/push'
        private_resource = RestClient::Resource.new pgURL, params[:user], params[:pass]
        private_resource.get{ |response, request, result, &block|
        if [301, 302, 307].include? response.code
        response.follow_redirection(request, result, &block)
        end
}

end


# Handle all other routing
["/:user", "/:user/", "/:user/:pass", "/:user/:pass/"].each do |path|
get_or_post path do
  haml  :error
end
end
