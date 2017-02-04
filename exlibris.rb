require 'sinatra'
require 'oauth'
 
enable :sessions
set :session_secret, 'exlibrissecretsdontmakefriends'

DEVELOPERKEY = ''
SECRET = ''

def makeConsumer                               
  consumer = OAuth::Consumer.new(DEVELOPERKEY, SECRET, {
    :site               => "http://www.goodreads.com",
    :request_token_path => "/oauth/request_token",
    :access_token_path  => "/oauth/access_token",
    :authorize_path     => "/oauth/authorize",
    :scheme             => :header
   })
   return consumer
end

def makeRequest_token 
	request_token = makeConsumer.get_request_token
	session[:request_token] = request_token
	return request_token
end

get '/' do 
	erb :index
end

get '/login' do
	redirect makeRequest_token.authorize_url
end

get '/goodreads_oauth_callback' do 
	request_token = session[:request_token]
	access_token = request_token.get_access_token oauth_verifier: params[:oauth_verifier]
		
	redirect '/books'
end

get '/books' do 
	puts session[:goodreads_client].request('/shelf/list.xml')
end