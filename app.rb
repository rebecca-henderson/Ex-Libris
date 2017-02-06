require 'sinatra'

require './controllers/oauth'
require './controllers/network'

include OAuth
include Network
 
enable :sessions
set :session_secret, 'exlibrissecretsdontmakefriends'

get '/' do 
	if (!session[:access_token])
		redirect '/login'
		return
	end
	
	@user = oauthGet('/api/auth_user')["user"]
	@books = oauthGet('/owned_books/user', "id" => @user["id"], "per_page" => "200")["owned_books"]["owned_book"]
	
	@unreadBooks = Array.new
	@books.each do |ownedBook| 
		hasBeenRead = false 
		bookShelvesList = ownedBook["review"]["shelves"] 
		bookShelvesList.each do |shelfArray| 
			shelfArray.each do |shelf| 
				if shelf["name"] == "read" 
					hasBeenRead = true 
				end 
			end 
		end 
		if !hasBeenRead 
			@unreadBooks.push(ownedBook)
		end 
	end 
	
	erb :index
end

get '/login' do
	redirect makeRequest_token.authorize_url
end

get '/goodreads_oauth_callback' do 
	request_token = session[:request_token]
	access_token = request_token.get_access_token oauth_verifier: params[:oauth_verifier]
	
	session[:access_token] = access_token
	
	redirect '/'
end

get '/search' do 
	puts "at search route"
	query = params["bookName"]
	@searchResults = oauthGet('/search/index.xml', "q" => query)["search"]["results"]["work"]
	erb :searchResults, :layout => false
end