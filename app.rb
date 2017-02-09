require 'sinatra'

require './controllers/oauth'
require './controllers/networkRequests'

include OAuth
include NetworkRequests
 
enable :sessions
set :session_secret, 'exlibrissecretsdontmakefriends'

helpers do
	# Checks the session for a previously stored user model. If it's not found, makes a Goodreads GET request for the user information. 
	def getUser 
		if !session[:user]
			session[:user] = oauthGet('/api/auth_user')["user"]
		end
		
		@user = session[:user]
	end
	
	# Gets a list of the user's owned books from Goodreads. Uses the userId stored in the session. Note: The Goodreads API does not paginate the owned books list response.
	def getBooks
		getUser
		#Goodreads API doesn't actually paginate their owned_books results which is...fun. Just requesting the max_number allowed for now.
		@allBooks = oauthGet('/owned_books/user', "id" => @user["id"], "per_page" => "200")["owned_books"]["owned_book"]
	end
	
	#Checks an ownedBook response for the presence of a review
	def bookHasReview(book)
		return book.has_key?("review")
	end
	
	#Checks an ownedBook response's review to see if any of the shelves contained in the review are the "Read" shelf.
	def bookHasBeenRead(book)
		hasBeenRead = false
		bookShelvesList = book["review"]["shelves"] 
		bookShelvesList.each do |shelfArray| 
			shelfArray.each do |shelf| 
				if shelf["name"] == "read" 
					hasBeenRead = true 
				end 
			end 
		end
		
		return hasBeenRead
	end
	
	#Finds all of the books in the @allBooks list (from def getBooks) that have not been read. There is no definite flag from the Goodreads API so instead this is derived from the the book's review (if present) and the shelf the book review appears on.
	def calculateUnreadBooks	
		@unreadBooks = Array.new
		@allBooks.each do |ownedBook| 
			hasBeenRead = false 
			
			if bookHasReview(ownedBook)
				hasBeenRead = bookHasBeenRead(ownedBook)
			end 
			
			if !hasBeenRead 
				@unreadBooks.push(ownedBook)
			end 
		end
	end 
	
	#Fetches the book list from Goodreads and calculates the unread books.
	def refreshBookList
		getBooks
		calculateUnreadBooks
	end
end

#Homepage
#If the access token is not stored in the session, redirects to /login to launch the OAuth sequence. 
#If the access token is present, grabs the book list from Goodreads and displays the main book list view.
get '/' do 
	if (!session[:access_token])
		redirect '/login'
		return
	end
	
	refreshBookList
	
	erb :index
end

#Kicks off the OAuth process. Called from GET / when the access_token is not present.
get '/login' do
	redirect makeRequest_token.authorize_url
end

#Called by Goodreads when the user has finished authenticating with them. Continues the OAuth process to get the access token using the request token, which it then stores in the session. Redirects back to GET / to kick off the book list loading.
get '/goodreads_oauth_callback' do 
	#FIXME: if the user did not allow access, we should not procede.
	request_token = session[:request_token]
	access_token = request_token.get_access_token oauth_verifier: params[:oauth_verifier]
	
	session[:access_token] = access_token
	
	redirect '/'
end

#Called from the 'Add to Library' nav bar button form submission. The default behavior of the form is overridden in /js/navbar.js and an AJAX request is sent instead. Sends the search query to Goodreads. If there are results, sends the searchResults.erb data back to the AJAX request, which is then rendered in the search modal. If there are no results found, failure.erb is rendered instead.
get '/search' do 
	@searchQuery = params["bookName"]
	pageNumber = params["pageNumber"]
	
	searchResultsResponse = oauthGet('/search/index.xml', "q" => @searchQuery, "page" => pageNumber)["search"]
	
	puts "testa"
	
	searchResultsArray = searchResultsResponse["results"]
	if !searchResultsArray || searchResultsArray.count == 0
		return erb :failure, :locals => {:message => "No results found."},  :layout => false
	end
	
	puts "test"
	
	searchResultsWorkList = searchResultsArray["work"]
	if !searchResultsWorkList
		return erb :failure, :locals => {:message => "No results found."},  :layout => false
	end
	puts "test2"
	
	#when there's only 1 result, the xml to hash conversion makes the results list a single hash instead of an array of one hash
	if searchResultsWorkList.is_a? Hash 
		@searchResults = [searchResultsWorkList]
	else
		@searchResults = searchResultsWorkList	
	end
	
	@totalResults = searchResultsResponse["total_results"].to_i
	@resultStart = searchResultsResponse["results_start"].to_i
	@resultEnd = searchResultsResponse["results_end"].to_i
	
	erb :searchResults, :layout => false
end

#Adds a book to the user's owned books list.
#Called when selecting an item from the search results list in the search modal. This request is sent via AJAX and returns success.erb or failure.erb data back for rendering.
post '/ownedBook' do 
	bookId = params["bookId"]
	
	didAddBook = oauthPost('/owned_books.xml', "owned_book[book_id]" => bookId)
	if didAddBook
		erb :success, :locals => {:message => "This book was successfully added to your library!"}, :layout => false
	else
		erb :failure, :locals => {:message => "There was an issue adding this book to your library. Please try again."}, :layout => false
	end
end

#Removes a book from the user's owned books list.
#Called when clicking the 'Remove from library' button on a book in the book list. This request is sent via AJAX and returns success.erb or failure.erb data back for rendering.
delete '/ownedBook' do 
	ownedBookId = params["ownedBookId"]
	
	puts ownedBookId
	
	didDeleteBook = oauthPost('/owned_books/destroy/'+ownedBookId.to_s)
	if didDeleteBook
		erb :success, :locals => {:message => "This book was successfully removed from your library!"}, :layout => false
	else
		erb :failure, :locals => {:message => "There was an issue removing this book to your library. Please try again."}, :layout => false
	end
end

#Kicks off the full book list request. 
#This is used when adding a new book to the library as an alternative to using the POST /ownedBook response's ownedBook -> bookId to get the new book information (owned book response don't return the same information as book info responses) and inserting it in the right place in the @allBooks list and the @unreadBooks list.
#In order to make the process slightly less obtrusive to the user than a simple refresh would be, the refreshBookLists performs the refresh request off the main thread, gets the new data and replaces the old list with the new list.
#FIXME: This should be replaced with a better method of getting newly added book information.
get '/refreshBookLists' do
	refreshBookList
	
	erb :index, :layout => false
end