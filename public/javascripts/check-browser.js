$(function(){

    var chrome = navigator.userAgent.toLowerCase().indexOf('chrome') > -1;
    if (chrome) {
        jQuery(".tag_button").css("margin-top",-16);
				jQuery(".tag_button").css("margin-right",-1);
    }
				 
				 
    var opera = navigator.userAgent.toLowerCase().indexOf('opera') > -1;
    if (opera) {
        jQuery("a.priority_add_link2 ").css("margin-left",5);
    }
				 
    var safari = navigator.userAgent.toLowerCase().indexOf('safari') > -1;
    if (safari) {
        jQuery("#nav li .sub").css("margin-top",-40);
        jQuery(".cb-save").css("margin-left",-79);
        jQuery(".cb-save label").css("margin-left",-76);
    }
				 
    var firefox = navigator.userAgent.toLowerCase().indexOf('firefox') > -1;
    if (firefox) {
        jQuery("#nav li .sub").css("margin-top",-40);
    }
		
    var Win = navigator.appVersion.indexOf("Win") != -1;
    if (Win && firefox) {
				/*alert("ffwin");*/
    }
				 
    var Linux = navigator.appVersion.indexOf("Linux") !=-1;
				if (Linux && chrome){
						jQuery(".fblike").css("margin-right",24);
					}

    var Linux = navigator.appVersion.indexOf("Linux") !=-1;
				if (Linux && firefox){
						alert("fflinux");
						jQuery(".fblike").css("margin-right",24);
					}

    var ie8com = document.documentMode && document.documentMode == 8;
    if (ie8com) {
        jQuery("a.priority_add_link2").css("margin-left",5);
				jQuery("priority_tag").css("margin-left",-40);
				jQuery(".Chapter_name").css("top",-3);
				jQuery("#priority_category input, #point_supports input, #point_opposes input").css("margin-bottom",5);
				jQuery(".point_supports_label, .point_opposes_label").css("top",-3);
    }

		var ie7com = document.documentMode && document.documentMode == 7;
    if (ie7com) {
        jQuery("a.priority_add_link2").css("float","left");
				jQuery("a.priority_add_link2").css("margin-left",5);
				jQuery(".fblike").css("margin-top",-15);
				jQuery("#user_info_box").css("z-index",-1);
				jQuery("#user_info_box").css("position","relative");
				jQuery(".test").css("z-index",100);
				jQuery(".tag_button").css("margin-top",-15);
				jQuery(".Chapter_name").css("top",-8);
				jQuery("#priority_category input, #point_supports input").css("margin-bottom",5);
				jQuery(".point_supports_label, .point_opposes_label").css("top",-8);
    }


    var ie9com = document.documentMode && document.documentMode == 9;
    if (ie9com) {
				/*jQuery(".category").css("margin-left",10);
				jQuery(".category").css("margin-top",-15);
        jQuery("a.priority_add_link2").css("margin-left",5);
				jQuery("priority_tag").css("margin-left",-40);*/
    }
    
				
    if(jQuery.browser.version.substring(0, 2) == "8.") {
        jQuery("#nav li .sub").css("margin-top",-39);
        jQuery(".cb-save").css("margin-left",-79);
        jQuery(".cb-save label").css("margin-left",-76);
    }
		
});
