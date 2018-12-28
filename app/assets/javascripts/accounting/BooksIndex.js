var BooksIndex  = (function() {
  var $btnPrint;
  var $inputStartDate;
  var $inputEndDate;
  var $selectBranch;
  var $modalPrint;
  var $message;

  var book;
  var authenticityToken;

  var _urlPrint = "/api/v1/print/generate_file";

  var _cacheDom = function() {
    $btnPrint       = $("#btn-print");
    $inputStartDate = $("#input-start-date");
    $inputEndDate   = $("#input-end-date");
    $selectBranch   = $("#select-branch");
    $modalPrint     = $("#modal-print");
    $message        = $(".message");
  };

  var _bindEvents = function() {
    $btnPrint.on("click", function() {
      var startDate = $inputStartDate.val();
      var endDate   = $inputEndDate.val();
      var branchId  = $selectBranch.val();

      if(!startDate) {
        alert("Start date required");
      }

      if(!endDate) {
        alert("End date required");
      }

      $modalPrint.modal("show");
      $message.html("Printing...");

      $.ajax({
        url: _urlPrint,
        method: 'POST',
        data: {
          start_date: startDate,
          end_date: endDate,
          branch_id: branchId,
          book: book,
          type: "book",
          authenticity_token: authenticityToken
        },
        success: function(response) {
          $message.html(
            "Success! Redirecting..."
          );

          $modalPrint.modal("hide");
          window.open("/print?filename=" + response.filename, '_blank');
        },
        error: function(response) {
          $message.html("Error!");
        }
      });
    });
  };

  var init  = function(options) {
    authenticityToken = options.authenticityToken;
    book              = options.book;

    _cacheDom();
    _bindEvents();
  };

  return  {
    init: init
  };
})();
