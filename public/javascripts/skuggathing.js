jQuery(document).ready(function() {
	if (location.pathname.substring(1,19) != 'priority_processes') {
		jQuery(".althingi_process_container").addClass("hidden");
		jQuery(".althingi_process_container").children("span.showorhide").text("sjá");
		foobar();
	}
	else {
		jQuery(".althingi_process_container").addClass("shown");
		jQuery(".althingi_process_container p span").text("fela");
		jQuery(".althingi_process_container p span").text("fela");
		foobar();
	}
	
	jQuery(".althingi_process_container h2, .althingi_process_container p").css("cursor","pointer");
	
	function foobar() {
		jQuery(".althingi_process_container.hidden h2, .althingi_process_container.hidden p").click(function() {
			jQuery(this).siblings().slideDown();
			jQuery(this).siblings().children("span.showorhide").text("fela");
			jQuery(this).children("span.showorhide").text("fela");
			foobar();
		});
		jQuery(".althingi_process_container.shown h2, .althingi_process_container.shown p").click(function() {
			jQuery(this).siblings("div").slideUp();
			jQuery(this).parent().addClass("hidden");
			jQuery(this).parent().removeClass("shown");
			jQuery(this).siblings().children("span.showorhide").text("sjá");
			jQuery(this).children("span.showorhide").text("sjá");
			foobar();
		});
	}
	foobar();
});