require 'active_support/core_ext/hash'
require 'uri'

module NetworkRequests
	#Base URL for all requests
	API_URL = 'http://www.goodreads.com'
	
	#Uses the access token stored in the session to make a get request to the given path. If parameters are provided, these are encoded and added to the path.
	#Returns the parsed response or throws an exception if an error was encountered. 
	def oauthGet(path, requestParameters = nil)
				
		accessToken = session[:access_token]
		
		if requestParameters
        	path = addParametersToPath(requestParameters, path)
      	end
      
      	response = accessToken.get(path, "Accept" => "application/xml")
      	
      	checkResponseForErrors(response)
      	
      	return parse(response)
	end
	
	#Uses the access token stored in the session to make a post request to the given path. If parameters are provided, these are passed with the request.
	#Returns a bool indicating if the request was successful or throws an exception if an error was encountered. 
	def oauthPost(path, requestParameters = nil)
				
		accessToken = session[:access_token]
      
      	response = accessToken.post(path, requestParameters, "Accept" => "application/xml")
      	
      	checkResponseForErrors(response)
      	    
      	#FIXME: more rigorous response checking here. Should we return the post response data anyway?	
      	return true
	end
	
	private
	
	#Checks for response errors and throws an exception if any are found.
	#FIXME: This needs to be better... More thorough and more graceful error handling.
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
	
	#Maps over the given requestParameters to encode them and then joins them all with an ampersand.
	def queryParameters(requestParameters)
		requestParameters.map { |k, v| 
			encodedKey = URI.escape(k)
			encodedValue = URI.escape(v)
			"#{encodedKey}=#{encodedValue}" 
		}.join("&")
	end
	
	#Encodes the given requestParameters, joins them and appends them to the given path.
	def addParametersToPath(requestParameters, path)
		return "#{path}?#{queryParameters(requestParameters)}"
	end
	
	#Takes an XML response from a Goodreads API request and converts it into a hash. Drills down into the universal "GoodreadsResponse" key and removes the "Request" key.
	def parse(response)
	
		hash = Hash.from_xml(response.body)
		
		goodreadsResponse = hash["GoodreadsResponse"]
      	goodreadsResponse.delete("Request")
      	
      	return goodreadsResponse
	end
end