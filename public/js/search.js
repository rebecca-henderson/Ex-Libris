$( document ).ready(function() {	
	$("#searchForm").submit(function(event){
		event.preventDefault();//to stop the submit
		performSearch($("input[name='bookName']").val(), 1);						
	});
});

var clearSearchResultsAndShowSpinner = function() {
	$('.search-results').hide();
	$('.spinner').show();
}

var showResultsAndHideSpinner = function(data) {
	$('.spinner').hide();
	$('.search-results').html(data).show();
}

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

var addBookToLibrary = function(bookId) {		
	clearSearchResultsAndShowSpinner()
		
	$.ajax({
		url: "/ownedBook",
		method: "POST",
		data: { "bookId": bookId },
		dataType: "html",
		success: function(data) {
			showResultsAndHideSpinner(data);
			addNewlyAddedBookToBookLists();
		}, 
		error: function(data) {
			console.log(data);
		}
	});
};