require 'rest-client'
require 'active_support/core_ext/hash'
require 'uri'

module Network
	API_URL = 'http://www.goodreads.com'
	RESPONSE_FORMAT = 'xml'
	
	# def get(path, requestParameters = {})
# 		parameters = constructParameters(requestParameters)
#      	url = "#{API_URL}#{path}"
# 
# 		response = RestClient.get(url, params: parameters)
# 
#       	return parse(response)
# 	end
	
	def oauthGet(path, requestParameters = nil)
		
		#API terms of use requires no more than one request per second
		sleep(1)
		
		accessToken = session[:access_token]
		
		if requestParameters
        	path = addParametersToPath(requestParameters, path)
      	end
      
      	response = accessToken.get(path, "Accept" => "application/xml")
      	return parse(response)
	end
	
	private
	
	def queryParameters(requestParameters)
		return requestParameters.map { |k, v| 
			encodedKey = URI.escape(k)
			encodedValue = URI.escape(v)
			return "#{encodedKey}=#{encodedValue}" 
		}.join("&")
	end
	
	def addParametersToPath(requestParameters, path)
		return "#{path}?#{queryParameters(requestParameters)}"
	end
	
	# def constructParameters(requestParameters = {})
# 		#add response format key and api request token
# 		requestParameters.merge!(format: RESPONSE_FORMAT, key: @token)
# 		return requestParameters
# 	end
	
	def parse(response)
	
		hash = Hash.from_xml(response.body)
				
		goodreadsResponse = hash["GoodreadsResponse"]
      	goodreadsResponse.delete("Request")
      	
      	return goodreadsResponse
	end
end