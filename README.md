# Ex Libris
This is a Sinatra app that allows Goodreads users to view books in their 'Owned Books' list and add new books to their library.

Toggle between unread books in your library and all of your owned books by selecting the links in the navigation bar. 

To add a new book to your library, search for the book name in the search bar and select the correct book from the results list.

# Set Up
Download the repository, then run `bundle install` from the command line to install necessary Ruby components.

Run `rackup` to launch the application at http://localhost:9292.

This requires a Goodreads account. Sign up at goodreads.com and then head to goodreads.com/api to obtain a developer key and secret key. Add your keys to /controllers/oauth.rb.

# To Do
* Better Network response error handling. More robust and more graceful.
* Better way to update the book list after adding a new book to the library. Currently the whole list is refetched, re-rendered and replaced.
* Center loading spinner in search modal.
* Use generic modalAlert when displaying responses from POST /ownedBook rather than reusing the search modal.
* If deleting the last book in the library it should go back to the empty library view


# Enhancements
* Show book cover images in book list panel body and in search requests.
* Show personal book ratings and reviews.
* Allow editing of other 'owned book' attributes (condition, purchase date/location, etc).
* Pick a shelf to add newly added books to. (i.e. 'Want to Read', 'Currently Reading', etc)



