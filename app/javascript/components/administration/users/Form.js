import React, { useEffect, useState } from "react";
import { hasFormError } from "../../../helpers/AppHelper";

export default Form = (props) => {
  const [user, setUser] = useState({
    username: "",
    email: "",
    identification_number: "",
    first_name: "",
    last_name: "",
    password: "",
    password_confirmation: ""
  })

  const [isLoading, setIsLoading] = useState(false);
  const [errors, setErrors]       = useState({});

  useEffect(() => {
    if (props.id) {
    }
  });

  return (
    <React.Fragment>
      <div className="row">
        <div className="col-md-6 col-xs-12">
          <div className="form-group">
            <div className="form-label">
              First Name
            </div>
            <input
              value={user.first_name}
              className={`form-control ${hasFormError(errors, 'first_name') ? 'is-invalid' : ''}`}
              disabled={isLoading}
              onChange={(event) => {
                let _user = {...user}
                _user.first_name = event.target.value;
                setUser(_user);
              }}
            />
            <div className="invalid-feedback">
              {hasFormError(errors, 'first_name') ? errors.first_name.join(', ') : ''}
            </div>
          </div>
        </div>
        <div className="col-md-6 col-xs-12">
          <div className="form-group">
            <div className="form-label">
              Last Name
            </div>
            <input
              value={user.last_name}
              className={`form-control ${hasFormError(errors, 'last_name') ? 'is-invalid' : ''}`}
              disabled={isLoading}
              onChange={(event) => {
                let _user = {...user}
                _user.last_name = event.target.value;
                setUser(_user);
              }}
            />
            <div className="invalid-feedback">
              {hasFormError(errors, 'last_name') ? errors.last_name.join(', ') : ''}
            </div>
          </div>
        </div>
      </div>
      <div className="row">
        <div className="col-md-4 col-xs-12">
          <div className="form-group">
            <div className="form-label">
              Email
            </div>
            <input
              value={user.email}
              className={`form-control ${hasFormError(errors, 'email') ? 'is-invalid' : ''}`}
              disabled={isLoading}
              onChange={(event) => {
                let _user = {...user}
                _user.email = event.target.value;
                setUser(_user);
              }}
            />
            <div className="invalid-feedback">
              {hasFormError(errors, 'email') ? errors.email.join(', ') : ''}
            </div>
          </div>
        </div>
        <div className="col-md-4 col-xs-12">
          <div className="form-group">
            <div className="form-label">
              Username
            </div>
            <input
              value={user.username}
              className={`form-control ${hasFormError(errors, 'username') ? 'is-invalid' : ''}`}
              disabled={isLoading}
              onChange={(event) => {
                let _user = {...user}
                _user.username = event.target.value;
                setUser(_user);
              }}
            />
            <div className="invalid-feedback">
              {hasFormError(errors, 'username') ? errors.username.join(', ') : ''}
            </div>
          </div>
        </div>
        <div className="col-md-4 col-xs-12">
          <div className="form-group">
            <div className="form-label">
              Identification Number
            </div>
            <input
              value={user.identification_number}
              className={`form-control ${hasFormError(errors, 'identification_number') ? 'is-invalid' : ''}`}
              disabled={isLoading}
              onChange={(event) => {
                let _user = {...user}
                _user.identification_number = event.target.value;
                setUser(_user);
              }}
            />
            <div className="invalid-feedback">
              {hasFormError(errors, 'identification_number') ? errors.identification_number.join(', ') : ''}
            </div>
          </div>
        </div>
      </div>
    </React.Fragment>
  )
}
