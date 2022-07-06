import Mustache from "mustache";
import axios from 'axios';
import * as bootstrap from "bootstrap";

let urlLogin          = "/api/users/login";
let urlForgotPassword = "/api/users/forgot_password";
let loadingText       = '<i class="fa fa-spin"></i> Loading...';
let errorList         = "";
let isLoading         = false;

let $inputUsername;
let $inputPassword;
let $inputEmail;
let $btnLogin;
let $btnForgotPassword;
let $btnSendemail
let $modalSendForgotPassword;
let $message;
let $messageModal;

const _cacheDom = function() {
  errorList           = document.querySelector("#template-error-list").innerHTML;
  $inputUsername      = document.querySelector("#input-username");
  $inputPassword      = document.querySelector("#input-password");
  $inputEmail         = document.querySelector("#input-email");
  $btnLogin           = document.querySelector("#btn-login");
  $btnForgotPassword  = document.querySelector("#btn-forgot-password");
  $btnSendEmail       = document.querySelector("#btn-send-email");
  $message            = document.querySelector(".message");
  $messageModal       = document.querySelector("#message-modal");

  $modalSendForgotPassword = new bootstrap.Modal(
    document.getElementById("modal-send-forgot-password")
  )
};

const _bindEvents = function() {
  $btnSendEmail.addEventListener("click", function() {
    $messageModal.innerHTML = "";

    const data = {
      email:  $inputEmail.value
    }

    _toggleInput();

    axios.post(
      urlForgotPassword,
      data,
      {}
    ).then((response) => {
      console.log(response);

      $messageModal.innerHTML = "Email sent!";
      $inputEmail.value = "";
      _toggleInput();
    }).catch((error) => {
      try {
        var obj = error.response.data.errors;

        var errors = []

        for(const key in obj) {
          errors.push(obj[key]);
        }

        $messageModal.innerHTML = Mustache.render(
          errorList,
          { errors: errors }
        );

        _toggleInput();
      } catch(e) {
        console.log(e);
        $message.innerHTML = "Something went wrong...";
        _toggleInput();
      }
    });
  });

  $btnForgotPassword.addEventListener("click", function() {
    $modalSendForgotPassword.show();
  });

  $inputUsername.focus();

  $inputUsername.addEventListener("keyup", function(e) {
    if(e.keyCode == 13) {
      $btnLogin.click();
    }
  });

  $inputPassword.addEventListener("keyup", function(e) {
    if(e.keyCode == 13) {
      $btnLogin.click();
    }
  });

  $btnLogin.addEventListener("click", function() {
    const data  = {
      username: $inputUsername.value,
      password: $inputPassword.value
    };

    _toggleInput();

    axios.post(
      urlLogin,
      data,
      {}
    ).then((response) => {
      window.location.href = "/";
    }).catch((error) => {
      try {
        var obj = error.response.data.errors;

        var errors = []

        for(const key in obj) {
          errors.push(obj[key]);
        }

        $message.innerHTML = Mustache.render(
          errorList,
          { errors: errors }
        );

        _toggleInput();

        $inputUsername.focus();
      } catch(e) {
        console.log(e);
        $message.innerHTML = "Something went wrong...";
        _toggleInput();
      }
    });
  });
};

var _toggleInput = function() {
  isLoading = !isLoading;
  $inputUsername.disabled = isLoading;
  $inputPassword.disabled = isLoading;
  $btnLogin.disabled      = isLoading;
  $inputEmail.disabled    = isLoading;
  $btnSendEmail           = isLoading;
};

var init  = function() {
  _cacheDom();
  _bindEvents();
};

export default { init: init };
