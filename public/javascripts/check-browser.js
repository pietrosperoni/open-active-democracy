$(function(){

    var chrome = navigator.userAgent.toLowerCase().indexOf('chrome') > -1;
    if (chrome) {
        jQuery(".tag_button").css("margin-top",-16);
				jQuery(".tag_button").css("margin-right",-1);
        /*jQuery(".cb-save").css("margin-left",-79);
        jQuery(".cb-save label").css("margin-left",-76);*/
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
        jQuery("#nav li .sub").css("margin-top",-39);
        jQuery("#nav li .sub").css("margin-left",200);
        jQuery("#body .right-body .bonus").css("margin-top",-4);
        jQuery(".little-arrow").css("margin-top",4);
    }
    
				
    if(jQuery.browser.version.substring(0, 2) == "8.") {
        jQuery("#nav li .sub").css("margin-top",-39);
        jQuery(".cb-save").css("margin-left",-79);
        jQuery(".cb-save label").css("margin-left",-76);
    }
		
});
