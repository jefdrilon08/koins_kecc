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
    password_confirmation: "",
    roles: []
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
            <label className="form-label">
              First Name
            </label>
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
            <label className="form-label">
              Last Name
            </label>
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
            <label className="form-label">
              Email
            </label>
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
            <label className="form-label">
              Username
            </label>
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
            <label className="form-label">
              Identification Number
            </label>
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
      <div className="row">
        <div className="col-md-4 col-xs-12">
          <div className="form-group">
            <label className="form-label">
              Roles
            </label>
            {props.roles.map((role) => {
              return (
                <React.Fragment key={`role-${role}`}>
                  <div>
                    <input
                      type="checkbox"
                      className="form-check-input"
                      checked={user.roles.includes(role)}
                      disabled={isLoading}
                      onChange={(e) => {
                        let roles = [...user.roles];

                        if (roles.includes(role)) {
                          const roleIndex = roles.indexOf(role);
                          roles.splice(roleIndex, 1);
                        } else {
                          roles.push(role);
                        }

                        let _user = {...user};
                        _user.roles = roles;
                        setUser(_user);
                      }}
                    />
                    <label className="form-label ms-2">
                      {role}
                    </label>
                  </div>
                </React.Fragment>
              )
            })}
            <div className="invalid-feedback">
              {hasFormError(errors, 'roles') ? errors.roles.join(', ') : ''}
            </div>
          </div>
        </div>
        <div className="col-md-8 col-xs-12">
          <div className="form-group">
            <label className="form-label">
              Profile Picture
            </label>
            <input
              value={user.profile_picture}
              type="file"
              className={`form-control ${hasFormError(errors, 'profile_picture') ? 'is-invalid' : ''}`}
              disabled={isLoading}
              onChange={(event) => {
                let _user = {...user}
                _user.profile_picture = event.target.value;
                setUser(_user);
              }}
            />
            <div className="invalid-feedback">
              {hasFormError(errors, 'profile_picture') ? errors.profile_picture.join(', ') : ''}
            </div>
            <label className="form-label mt-2">
              Incentivized Date
            </label>
            <input
              value={user.incentivized_date}
              className={`form-control ${hasFormError(errors, 'incentivized_date') ? 'is-invalid' : ''}`}
              disabled={isLoading}
              type="date"
              onChange={(event) => {
                let _user = {...user}
                _user.incentivized_date = event.target.value;
                setUser(_user);
              }}
            />
            <div className="invalid-feedback">
              {hasFormError(errors, 'incentivized_date') ? errors.incentivized_date.join(', ') : ''}
            </div>
            <div className="mt-2"/>
            <input
              checked={user.is_regular ? true : false}
              type="checkbox"
              className={`form-check-input ${hasFormError(errors, 'is_regular') ? 'is-invalid' : ''}`}
              disabled={isLoading}
              onChange={(event) => {
                let _user = {...user}

                _user.is_regular = !user.is_regular;
                setUser(_user);
              }}
            />
            <label className="form-label ms-2">
              Is Regular
            </label>
            <div className="invalid-feedback">
              {hasFormError(errors, 'is_regular') ? errors.is_regular.join(', ') : ''}
            </div>
          </div>
        </div>
      </div>
    </React.Fragment>
  )
}
