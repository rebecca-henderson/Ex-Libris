$( document ).ready(function() {	
	makeUnreadBooksActive();

	$("a#allBooksNavLink").click(function(event){
		makeAllBooksActive();
	});
	
	$("a#unreadBooksNavLink").click(function(event){
		makeUnreadBooksActive();
	});
});

//Hides the all books list, shows the unread books list (from index.erb) and makes the unread lists nav pill active (from navPills.erb).
var makeUnreadBooksActive = function() {
	$("div.allBooks").hide();
	$("div.unreadBooks").show();
	
	$("li#unreadBooksNavItem").attr("class", "active")
	$("li#allBooksNavItem").removeAttr("class")
};

//Hides the all books list, shows the unread books list and makes the unread lists nav pill active.
var makeAllBooksActive = function() {
	$("div.unreadBooks").hide();
	$("div.allBooks").show();
			
	$("li#allBooksNavItem").attr("class", "active")
	$("li#unreadBooksNavItem").removeAttr("class")
};