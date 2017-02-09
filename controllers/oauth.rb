require 'oauth'

module OAuth

#Provided by Goodreads API
#https://www.goodreads.com/api
DEVELOPERKEY = ''
SECRET = ''
	
	#Creates our OAuth consumer object using the urls and keys provided by Goodreads
	def makeConsumer      
		if DEVELOPERKEY == '' || SECRET == ''
			fail "Add your Goodreads developer key and secret key in /controllers/oauth.rb"
		end
	                         
		consumer = OAuth::Consumer.new(DEVELOPERKEY, SECRET, {
		:site               => "http://www.goodreads.com",
		:request_token_path => "/oauth/request_token",
		:access_token_path  => "/oauth/access_token",
		:authorize_path     => "/oauth/authorize",
		:scheme             => :header
		})
		return consumer
	end

	#Begins the OAuth process by creating an OAuth consumer and getting a request token which is then stored in the session.
	def makeRequest_token 
		request_token = makeConsumer.get_request_token
		session[:request_token] = request_token
		return request_token
	end

end