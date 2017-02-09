$( document ).ready(function() {
	//Prevents the navBar search form default behavior and passes it off to the search request instead.
	$("#searchForm").submit(function(event){
		event.preventDefault();//to stop the submit
		performSearch($("input[name='bookName']").val(), 1);						
	});
});

//Starts the search loading spinner
var clearSearchResultsAndShowSpinner = function() {
	$('.search-results').hide();
	$('.spinner').show();
}

//Stops the search loading spinner and shows the given search results HTML
var showResultsAndHideSpinner = function(searchResultsHtml) {
	$('.spinner').hide();
	$('.search-results').html(searchResultsHtml).show();
}

//Sends a search request and displays the results.
var performSearch = function(bookName, pageNumber) {		
	clearSearchResultsAndShowSpinner()
		
	$.ajax({
		url: "/search",
		data: { "bookName": bookName, "pageNumber": pageNumber },
		dataType: "html",
		success: function(data) {
			showResultsAndHideSpinner(data);
		}, 
		error: function(data) {
			console.log(data);
		}
	});
};

//Sends off a request to refresh the book list after a new book is added to the library. This is an imperfect solution. See app.rb /refreshBookLists.
var addNewlyAddedBookToBookLists = function() {
	$.ajax({
		url: "/refreshBookLists",
		dataType: "html", 
		success: function(data) {
			$("#bookLists").html(data);
			makeUnreadBooksActive();
		},
		error: function(data) {
			console.log(data);
		}
	});
};

//Sends off a request to POST /ownedBook to add a book from the search results to our library. 
//Shows whether the request succeeded or failed in the modal and then kicks off a request to refresh the book list.
var addBookToLibrary = function(bookId) {		
	clearSearchResultsAndShowSpinner()
		
	$.ajax({
		url: "/ownedBook",
		method: "POST",
		data: { "bookId": bookId },
		dataType: "html",
		success: function(responseHtml) {
			showResultsAndHideSpinner(responseHtml);
			addNewlyAddedBookToBookLists();
		}, 
		error: function(data) {
			console.log(data);
		}
	});
};