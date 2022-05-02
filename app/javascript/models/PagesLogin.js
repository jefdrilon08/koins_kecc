import Mustache from "mustache";

var url         = "/api/v1/login";
var loadingText = '<i class="fa fa-spin"></i> Loading...';
var errorList   = "";
var isLoading   = false;

var $inputUsername;
var $inputPassword;
var $btnLogin;
var $message;

var authenticityToken;

var _cacheDom = function() {
  errorList         = $("#template-error-list").html();
  authenticityToken = $("meta[name='csrf-token']").attr('content');

  $inputUsername      = $("#input-username");
  $inputPassword      = $("#input-password");
  $btnLogin           = $("#btn-login");
  $message            = $(".message");
};

var _bindEvents = function() {
  $inputUsername.focus();

  $inputUsername.keyup(function(e) {
    if(e.keyCode == 13) {
      $btnLogin.click();
    }
  });

  $inputPassword.keyup(function(e) {
    if(e.keyCode == 13) {
      $btnLogin.click();
    }
  });

  $btnLogin.on("click", function() {
    var data  = {
      username: $inputUsername.val(),
      password: $inputPassword.val(),
      authenticity_token: authenticityToken
    };

    _toggleInput();

    $.ajax({
      url: url,
      method: 'POST',
      data: data,
      dataType: 'json',
      success: function(response) {
        window.location.href = "/";
      },
      error: function(response) {
        try {
          var payload = JSON.parse(response.responseText);
          var errors  = payload.errors.full_messages;
          $message.html(
            Mustache.render(
              errorList,
              { errors: errors }
            )
          );

          _toggleInput();

          $inputUsername.focus();
        } catch(e) {
          console.log(e);
          $message.html("Something went wrong...");
          _toggleInput();
        }
      }
    });
  });
};

var _toggleInput = function() {
  isLoading = !isLoading;
  $inputUsername.prop("disabled", isLoading);
  $inputPassword.prop("disabled", isLoading);
  $btnLogin.prop("disabled", isLoading);

  if(isLoading) {
    $btnLogin.data('original-text', $btnLogin.html());
    $btnLogin.html(loadingText);
  } else {
    $btnLogin.html($btnLogin.data('original-text'));
  }
};
var init  = function() {
  _cacheDom();
  _bindEvents();
};

export default { init: init };
