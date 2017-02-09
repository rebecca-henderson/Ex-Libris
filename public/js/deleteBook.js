//Called when clicking the "Remove from Library" button on a book in a book list.
//Makes the DELETE /ownedBook request, then displays the returned success/failure HTML in the modal alert and hides the book that was just removed. 
var removeBookFromLibrary = function(ownedBookId) {		
	$.ajax({
		url: "/ownedBook",
		method: "DELETE",
		data: { "ownedBookId" : ownedBookId },
		dataType: "html",
		success: function(alertHtml) {
			showAlert(alertHtml);
			removeBookFromBookLists(ownedBookId)
		}, 
		error: function(data) {
			console.log(data);
		}
	});
};

//Hides the book panel (from bookList.erb) from the book list.
var removeBookFromBookLists = function(removedBookId) {
	$('#unreadBooksPanel'+removedBookId).remove()
	$('#allBooksPanel'+removedBookId).remove()
};

//Shows the modalAlert (modalAlert.erb) and populates the alert body with the given html. This html is returned from the DELETE /ownedBook request.
var showAlert = function(alertHtml) {
	$('.modalAlertBody').html(alertHtml);
	$('#modalAlert').modal('show');
}