require 'active_support/core_ext/hash'
require 'uri'

module NetworkRequests
	API_URL = 'http://www.goodreads.com'
	RESPONSE_FORMAT = 'xml'
	
	def oauthGet(path, requestParameters = nil)
				
		accessToken = session[:access_token]
		
		if requestParameters
        	path = addParametersToPath(requestParameters, path)
      	end
      
      	response = accessToken.get(path, "Accept" => "application/xml")
      	
      	checkResponseForErrors(response)
      	
      	return parse(response)
	end
	
	def oauthPost(path, requestParameters = nil)
				
		accessToken = session[:access_token]
      
      	response = accessToken.post(path, requestParameters, "Accept" => "application/xml")
      	
      	checkResponseForErrors(response)
      	
      	return true
	end
	
	private
	
	def checkResponseForErrors(response) 
		case response
		when Net::HTTPUnauthorized
			fail (response.message)
		when Net::HTTPNotFound
			fail (response.message)
		when Net::HTTPInternalServerError
			fail (response.message)
		end
	end
	
	def queryParameters(requestParameters)
		requestParameters.map { |k, v| 
			encodedKey = URI.escape(k)
			encodedValue = URI.escape(v)
			"#{encodedKey}=#{encodedValue}" 
		}.join("&")
	end
	
	def addParametersToPath(requestParameters, path)
		return "#{path}?#{queryParameters(requestParameters)}"
	end
	
	def parse(response)
	
		hash = Hash.from_xml(response.body)
		
		goodreadsResponse = hash["GoodreadsResponse"]
      	goodreadsResponse.delete("Request")
      	
      	return goodreadsResponse
	end
end