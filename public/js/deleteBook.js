// $( document ).ready(function() {
// 	$('#modalAlert').on('show.bs.modal', function (event) {
// 	
// 	});
// });

var removeBookFromLibrary = function(ownedBookId) {		
	$.ajax({
		url: "/ownedBook",
		method: "DELETE",
		data: { "ownedBookId" : ownedBookId },
		dataType: "html",
		success: function(data) {
			showAlert(data);
			removeBookFromBookLists(ownedBookId)
		}, 
		error: function(data) {
			console.log(data);
		}
	});
};

var removeBookFromBookLists = function(removedBookId) {
	$('#unreadBooksPanel'+removedBookId).collapse('hide')
};

var showAlert = function(alertHtml) {
	$('.modalAlertBody').html(alertHtml);
	$('#modalAlert').modal('show');
}