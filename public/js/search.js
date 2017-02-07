$( document ).ready(function() {
	console.log( "ready!" );
	
	$("#searchForm").submit(function(event){
		event.preventDefault();//to stop the submit	
		
		$('.spinner').show();
		
		//send an ajax request to our action
		$.ajax({
			url: "/search",
			data: $(this).serialize(),
			dataType: "html",
			success: function(data) {
				console.log(data)
				$('.spinner').hide();
				$('.search-results').html(data).show();
			}
		});				
	});
	
	$(".search-close").click(function(event) {
		$('.search-results').hide();
		$('.spinner').show();
	});
});