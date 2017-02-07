$( document ).ready(function() {	
	$("#allBooksLink").click(function(event){
		makeAllBooksActive();
	});
	
	$("#unreadBooksLink").click(function(event){
		makeUnreadBooksActive();
	});
});

var makeUnreadBooksActive = function() {
	$(".allBooks").hide();
	$(".unreadBooks").show();
	
	$("div #allBooksCurrent").html("");	
	$("div #unreadBooksCurrent").html("<span class='sr-only'>(current)</span>");	
}

var makeAllBooksActive = function() {
	$(".unreadBooks").hide();
	$(".allBooks").show();
			
	$("div #unreadBooksCurrent").html("");
	$("div #allBooksCurrent").html("<span class='sr-only'>(current)</span>");	
}