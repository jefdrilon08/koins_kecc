import Mustache from "mustache/mustache";

var $btnRegister;
var $btnConfirmRegister;
var $modalRegister;
var $inputPassword;
var $inputPasswordConfirmation;
var $memberFirstName;
var $memberLastName;
var $message;
var templateErrorList;

var _authenticityToken;

var _id;
var _memberFirstName;
var _memberLastName;

var _cacheDom = function() {
  $btnRegister                = $(".btn-register"); 
  $btnConfirmRegister         = $("#btn-confirm-register");
  $modalRegister              = $("#modal-register");
  $inputPassword              = $("#input-password");
  $inputPasswordConfirmation  = $("#input-password-confirmation");
  $memberFirstName            = $("#member-first-name");
  $memberLastName             = $("#member-last-name");
  $message                    = $(".message");
  templateErrorList           = $("#template-error-list").html();
}

var _bindEvents = function() {
  $btnRegister.on("click", function() {
    $message.html("");
    $modalRegister.modal("show");

    _id               = $(this).data('id');
    _memberFirstName  = $(this).data('first-name');
    _memberLastName   = $(this).data('last-name');

    $memberFirstName.html(_memberFirstName);
    $memberLastName.html(_memberLastName);
  });

  $btnConfirmRegister.on("click", function() {
    var password              = $inputPassword.val();
    var passwordConfirmation  = $inputPasswordConfirmation.val();

    $message.html("");

    var payload = {
      id: _id,
      password: password,
      password_confirmation: passwordConfirmation,
      authenticity_token: _authenticityToken
    }

    $inputPassword.prop("disabled", true);
    $inputPasswordConfirmation.prop("disabled", true);
    $btnConfirmRegister.prop("disabled", true);

    $.ajax({
      url: "/api/v1/members/register_member",
      method: 'POST',
      data: payload,
      success: function(response) {
        alert("Successfully registered member!");
        window.location.reload();
      },
      error: function(response) {
        console.log(response);
        var errors  = [];
        try {
          errors  = JSON.parse(response.responseText).errors;
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

          $inputPassword.prop("disabled", false);
          $inputPasswordConfirmation.prop("disabled", false);
          $btnConfirmRegister.prop("disabled", false);
        }
      }
    })
  });
}

var init  = function(options) {
  _authenticityToken  = options.authenticityToken;

  _cacheDom();
  _bindEvents();
}

export default { init: init }
