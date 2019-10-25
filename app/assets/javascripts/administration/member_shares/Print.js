var Print = (function() {
  var fetchElements = function(){
    $btnPrintMemberShares = $("#btn-print-member-shares");
    $center = ("#center")
  };

  var initializeEvents = function(){
     $btnPrintMemberShares.on("click", function(){
      alert ($center.val());
    }); 
  };
  var init = function(){
    fetchElements();
    initializeEvents();
  };
  return {
    init: init
  };

})();
