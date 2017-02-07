$( document ).ready(function() {
	console.log( "ready!" );
	
	$("#searchForm").submit(function(event){
		event.preventDefault();//to stop the submit
		performSearch($("input[name='bookName']").val(), 1);
						
	});
	
	$(".search-close").click(function(event) {
		$('.search-results').hide();
		$('.spinner').show();
	});
});

var performSearch = function(bookName, pageNumber) {		
	$('.spinner').show();
		
	//send an ajax request to our action
	$.ajax({
		url: "/search",
		data: { "bookName": bookName, "pageNumber": pageNumber },
		dataType: "html",
		success: function(data) {
			$('.spinner').hide();
			$('.search-results').html(data).show();
		}, 
		error: function(data) {
			console.log(data);
		}
	});
};