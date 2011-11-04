function updateSubTags(category_id) {
    $(".sub_tags").each(
        function(intIndex,b) {
           if (parseInt(b.id.split("_")[2])==category_id) {
               jQuery("#"+b.id).show();
           } else {
               jQuery("#"+b.id).hide();
           }
        }
    );

    $('.sub_tags input[type="radio"]').each(function(a,b){
      b.checked = false;
  });

}



