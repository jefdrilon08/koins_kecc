var Login = (function() {
  var url         = "/api/v1/login";
  var loadingText = '<i class="fa fa-spin"></i> Loading...';
  var errorList   = "";
  var isLoading   = false;

  var $inputUsername;
  var $inputPassword;
  var $btnLogin;
  var $btnContactSupport;

  var authenticityToken;

  var _cacheDom = function() {
    errorList         = $("#template-error-list").html();
    authenticityToken = $("meta[name='csrf-token']").attr('content');

    $inputUsername      = $("#input-username");
    $inputPassword      = $("#input-password");
    $btnLogin           = $("#btn-login");
    $btnContactSupport  = $("#btn-contact-support");
    $message            = $(".message");
  };

  var _bindEvents = function() {
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
          window.location.href = "/dashboard";
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
          } catch(e) {
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

  return {
    init: init
  };
})();
