$( document ).ready(function() {	
	makeUnreadBooksActive();

	$("a#allBooksNavLink").click(function(event){
		makeAllBooksActive();
	});
	
	$("a#unreadBooksNavLink").click(function(event){
		makeUnreadBooksActive();
	});
});

var makeUnreadBooksActive = function() {
	$("div.allBooks").hide();
	$("div.unreadBooks").show();
	
	$("li#unreadBooksNavItem").attr("class", "active")
	$("li#allBooksNavItem").removeAttr("class")
};

var makeAllBooksActive = function() {
	$("div.unreadBooks").hide();
	$("div.allBooks").show();
			
	$("li#allBooksNavItem").attr("class", "active")
	$("li#unreadBooksNavItem").removeAttr("class")
};