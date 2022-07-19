import React, { useState, useEffect } from "react";
import ErrorList from '../ErrorList';
import axios from 'axios';

export default function MembersProfileMyKoins(props) {
  const [password, setPassword]               = useState("");
  const [passwordConfirm, setPasswordConfirm] = useState("");
  const [isLoading, setIsLoading]             = useState(false);

  const handleSavePassword = () => {
    const data = {
      password:               password,
      password_confirmation:  passwordConfirm
    }

    setIsLoading(true);
  }

  return (
    <>
      <h3>
        Change Password
      </h3>
      <div className="row">
        <div className="col">
          <div className="form-group">
            <label>
              Password
            </label>
            <input
              className="form-control"
              type="password"
              value={password}
              onChange={(event) => { setPassword(event.target.value) }}
              disabled={isLoading}
            />
          </div>
          <div className="form-group">
            <label>
              Password Confirmation
            </label>
            <input
              className="form-control"
              type="password"
              value={passwordConfirm}
              onChange={(event) => { setPasswordConfirm(event.target.value) }}
              disabled={isLoading}
            />
          </div>
          <hr/>
          <button 
            className="btn btn-success btn-block"
            onClick={handleSavePassword}
          >
            Save Password
          </button>
        </div>
      </div>
    </>
  )
}
