require 'oauth'

module OAuth

DEVELOPERKEY = 'YgSytTwCEIdC1HjOGgw'
SECRET = 't8H7uGaeJI9uGSKFGZAVFZaiGAJmZBCrm3j70QRaMFw'

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

end