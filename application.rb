require 'sinatra'
require 'rest_client'
require 'Haml'

def get_or_post(path, opts={}, &block)
  get(path, opts, &block)
  post(path, opts, &block)
end

get_or_post '/' do
  haml  :index
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
