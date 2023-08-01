import React, { useEffect, useState } from "react";
import SkCubeLoading from "../../SkCubeLoading";
import { fetchUser } from "../../../services/UsersService";

export default Show = (props) => {

  const [user, setUser] = useState({
    username: "",
    email: "",
    identification_number: "",
    first_name: "",
    last_name: "",
    full_name: "",
    password: "",
    password_confirmation: "",
    incentivized_date: "",
    profile_picture_url: "",
    roles: []
  })

  const [isLoading, setIsLoading] = useState(true);

  useEffect(() => {
    fetchUser(props.id)
      .then((payload) => {
        setUser(payload.data);
        setIsLoading(false);
      }).catch((payload) => {
        console.log(payload);
        alert("Error!");
        setIsLoading(true);
      });
  }, []);

  if (isLoading) {
    return (
      <SkCubeLoading/>
    )
  }

  return (
    <React.Fragment>
      <div className="container-fluid">
        <div className="card mt-2 mb-2">
          <div className="row g-0">
            <div className="col-md-12 col-xs-12">
              <div className="card-body">
                <center>
                  <img src={user.profile_picture_url} width="150px" height="150px"/>
                </center>
                <hr/>
                <h3>
                  {user.full_name}
                  <small className="text-muted ms-2">
                    {user.identification_number}
                  </small>
                </h3>
                <table className="table table-sm table-bordered">
                  <tbody>
                    <tr>
                      <th>
                        First Name
                      </th>
                      <td>
                        {user.first_name}
                      </td>
                    </tr>
                    <tr>
                      <th>
                        Last Name
                      </th>
                      <td>
                        {user.last_name}
                      </td>
                    </tr>
                    <tr>
                      <th>
                        Username
                      </th>
                      <td>
                        {user.username}
                      </td>
                    </tr>
                    <tr>
                      <th>
                        Email
                      </th>
                      <td>
                        {user.email}
                      </td>
                    </tr>
                    <tr>
                      <th>
                        Incentivized Date
                      </th>
                      <td>
                        {user.incentivized_date}
                      </td>
                    </tr>
                    <tr>
                      <th>
                        Is Regular
                      </th>
                      <td>
                        {(() => {
                          if (user.is_regular) {
                            return (
                              <span className="badge text-bg-success">
                                Yes
                              </span>
                            )
                          } else {
                            return (
                              <span className="badge text-bg-danger">
                                No
                              </span>
                            )
                          }
                        })()}
                      </td>
                    </tr>
                    <tr>
                      <th>
                        Roles
                      </th>
                      <td>
                        <ul>
                          {user.roles.filter((role) => { return role != "" }).map((role) => {
                            return (
                              <li key={`role-${user.id}-${role}`}>
                                {role}
                              </li>
                            )
                          })}
                        </ul>
                      </td>
                    </tr>
                  </tbody>
                </table>
              </div>
            </div>
          </div>
        </div>
      </div>
    </React.Fragment>
  )
}
