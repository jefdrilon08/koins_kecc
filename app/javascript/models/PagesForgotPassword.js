import Mustache from "mustache";
import axios from 'axios';

let urlChangePassword = "/api/users/change_password";

let $inputPassword;
let $inputPasswordConfirm;
let $btnConfirm;
let $message;
let token;
let verificationToken;
let errorList;

const _cacheDom = function() {
  $inputPassword        = document.querySelector("#input-password");
  $inputPasswordConfirm = document.querySelector("#input-password-confirm");
  $btnConfirm           = document.querySelector("#btn-confirm");
  $message              = document.querySelector(".message");
  errorList             = document.querySelector("#template-error-list").innerHTML;
};

const _bindEvents = function() {
  $btnConfirm.addEventListener("click", function() {
    const data = {
      password:           $inputPassword.value,
      password_confirm:   $inputPasswordConfirm.value,
      verification_token: verificationToken
    }

    const headers = {
    }

    const options = {
      headers: headers,
    }

    $inputPassword.disabled         = true;
    $inputPasswordConfirm.disabled  = true;
    $btnConfirm.disabled            = true;

    axios.post(
      urlChangePassword,
      data,
      options
    ).then((response) => {
      console.log(response);

      $message.innerHTML = "Password change successful!";
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
      } catch(e) {
        console.log(e);
        $message.innerHTML = "Something went wrong...";
      }

      $inputPassword.disabled         = false;
      $inputPasswordConfirm.disabled  = false;
      $btnConfirm.disabled            = false;
    });
  });
}

const init = function(options) {
  verificationToken = options.verification_token;

  _cacheDom();
  _bindEvents();
}

export default { init: init };
