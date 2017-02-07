require 'sinatra'

require './controllers/oauth'
require './controllers/networkRequests'

include OAuth
include NetworkRequests
 
enable :sessions
set :session_secret, 'exlibrissecretsdontmakefriends'

helpers do
	def getUser 
		if !session[:user]
			session[:user] = oauthGet('/api/auth_user')["user"]
		end
		
		@user = session[:user]
	end
	
	def getBooks
		if !session[:allBooks]
			getUser
			#Goodreads API doesn't actually paginate their owned_books results which is...fun. Just requesting the max_number allowed for now.
			session[:allBooks] = oauthGet('/owned_books/user', "id" => @user["id"], "per_page" => "200")["owned_books"]["owned_book"]
		end
		
		@allBooks = session[:allBooks]
	end
	
	def calculateUnreadBooks
		if session[:unreadBooks]
			@unreadBooks = session[:unreadBooks]
			return
		end
	
		@unreadBooks = Array.new
		@allBooks.each do |ownedBook| 
			hasBeenRead = false 
			if ownedBook["review"]
				bookShelvesList = ownedBook["review"]["shelves"] 
				bookShelvesList.each do |shelfArray| 
					shelfArray.each do |shelf| 
						if shelf["name"] == "read" 
							hasBeenRead = true 
						end 
					end 
				end
			end 
			if !hasBeenRead 
				@unreadBooks.push(ownedBook)
			end 
		end
		
		session[:unreadBooks] = @unreadBooks
	end
end

get '/' do 
	if (!session[:access_token])
		redirect '/login'
		return
	end
	
	getBooks	
	calculateUnreadBooks 
	
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
	@searchQuery = params["bookName"]
	pageNumber = params["pageNumber"]
	
	@searchResults = oauthGet('/search/index.xml', "q" => @searchQuery, "page" => pageNumber)["search"]
	
	erb :searchResults, :layout => false
end

post '/ownedBook' do 
	bookId = params["bookId"]
	
	@didAddBook = oauthPost('/owned_books.xml', "owned_book[book_id]" => bookId)
	if @didAddBook
		erb :ownedBookSuccess, :layout => false
	else 
		erb :ownedBookFailure, :layout => false
	end
end