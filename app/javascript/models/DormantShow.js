import Mustache from "mustache";
import $ from "jquery";
import * as bootstrap from "bootstrap";

var _authenticityToken;
var _id;

var $btnApprove;
var $modalApproveDormant;
var $btnConfirmProcess; 
var $btnAddOR;
var $btnAddSI;
var $inputParticular;
var $btnAddParticular;
var _urlAddParticular   = "/api/v1/data_stores/dormants/add_particular";
var _urlAddBookType     = "/api/v1/data_stores/dormants/add_book_type";
var $btnAddBook;
var $inputBookType;

var $message;
var templateErrorList;

var _cacheDom = function() {
	
  $modalApproveDormant = new bootstrap.Modal(
    document.getElementById("modal-approve-dormant")
  )

  // $modalApproveTransaction = new bootstrap.Modal(
  //   document.getElementById("modal-approve-transaction")
  // )

  $btnApprove            = $("#btn-approve");
  $btnConfirmProcess     = $("#btn-confirm-process");
  $inputOR               = $("#inputOR");
  $btnAddOR              = $("#btn-add-or");
  $inputSI               = $("#SI");
  $btnAddSI              = $("#btn-add-si");
  $message               = $(".message");
  $btnAddParticular      = $("#btn-add-particular");
  $inputParticular       = $("#particular");
  $btnAddBook             = $("#btn-add-book");
  $inputBookType          = $("#book_type");

};

var _bindEvents = function() {

    $btnAddParticular.on("click", function() {
        var txtParticular = $inputParticular.val()
          _id = $(this).data("id");	  
          $.ajax({	    
            url: _urlAddParticular,
            method: "POST",
            data: {
              id: _id,
              txtParticular: txtParticular,
              authenticity_token: _authenticityToken
            },
            success: function(response) {
              $message.html("Success!");
              window.location.reload();
            },
            error: function(response) {
              var errors  = [];
              try {
                errors  = JSON.parse(response.responseText).full_messages;
              } catch(err) {
                errors = ["Something went wrong"];
              } finally {
                $message.html(
                  Mustache.render(
                    templateErrorList,
                    { errors: errors }
                  )
                );
    
                $btnAddParticular.prop("disabled", false);
              }
            }
        });
      });

    $btnAddOR.on("click", function() {
        var txtOR = $inputOR.val()
        _id = $(this).data("id");
        
        var data = {
          id: _id,
          txtOR: txtOR,
          authenticity_token: _authenticityToken
        };  
        $.ajax({
            url: "/api/v1/data_stores/dormants/add_or",
            method: 'POST',
            data: data,
            success: function(response) {
            $message.html(
              "Success! Redirecting..."
            );
            window.location.reload();
          },
            error: function(response) {
            var errors  = [];
            try {
              errors  = JSON.parse(response.responseText).full_messages;
            } catch(err) {
              errors  = ["Something went wrong"]
            } finally {
              $message.html(
                Mustache.render(
                  templateErrorList,
                  { errors: errors }
                )
              );
            }
          }
        });	     
      });

    $btnAddSI.on("click", function() {
        var txtSI = $inputSI.val()
        
        _id = $(this).data("id");
        var data = {
          id: _id,
          txtSI: txtSI,
          authenticity_token: _authenticityToken
        };  
        $.ajax({
            url: "/api/v1/data_stores/dormants/add_si",
            method: 'POST',
            data: data,
            success: function(response) {
            $message.html(
              "Success! Redirecting..."
            );
            window.location.reload();
          },
            error: function(response) {
            var errors  = [];
            try {
              errors  = JSON.parse(response.responseText).full_messages;
            } catch(err) {
              errors  = ["Something went wrong"]
            } finally {
              $message.html(
                Mustache.render(
                  templateErrorList,
                  { errors: errors }
                )
              );
              $selectMember.prop("disabled", false);
            }
          }
        });	   
      });

      $btnAddBook.on("click", function() {
        var txtBookType = $inputBookType.val()   
        _id = $(this).data("id");    
         $.ajax({      
           url: _urlAddBookType,
           method: "POST",
           data: {
           id: _id,
           txtBookType:  txtBookType,
           authenticity_token: _authenticityToken
           },
           success: function(response) {
             $message.html("Success!");
             window.location.reload();
           },
           error: function(response) {
             var errors  = [];
   
             try {
               errors  = JSON.parse(response.responseText).full_messages;
             } catch(err) {
               errors = ["Something went wrong"];
             } finally {
               $message.html(
                 Mustache.render(
                   templateErrorList,
                   { errors: errors }
                 )
               );
   
               $btnAddBook.prop("disabled", false);
             }
           }
         });
     });

     $btnApprove.on("click", function() {
      _id = $(this).data("id");
      $modalApproveDormant.show();
    });

     $btnConfirmProcess.on("click", function() {
      var data = {
        id: _id,
        authenticity_token: _authenticityToken
      };
      $btnConfirmProcess.prop("disabled", true);
      $message.html("Loading...");
      console.log(data);
      $.ajax({
        url: "/api/v1/data_stores/dormants/approve",
        method: 'POST',
        data: data,
        success: function(response) {
          $message.html("Success! Redirecting...");
          window.location.href = "/data_stores/dormant";
        },
        error: function(response) {
          console.log(response);
          var errors  = [];
          try {
            errors  = JSON.parse(response.responseText).full_messages;
          } catch(err) {
            errors  = ["Something went wrong"];
            console.log(err);
          } finally {
            console.log(errors);
            $message.html(
              Mustache.render(
                templateErrorList,
                { errors: errors }
              )
            );
  
            $btnConfirmProcess.prop("disabled", false);
          }
        }
      });
    });

};


var init  = function(config) {
  _authenticityToken = config.authenticityToken;

  _cacheDom();
  _bindEvents();
}

export default { init: init };






