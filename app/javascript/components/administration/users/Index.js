import React, { useState, useEffect } from "react";
import { fetchUsers } from "../../../services/UsersService";
import Pagination from "../../commons/Pagination";

export default Index = (props) => {
  const [numPages, setNumPages]   = useState(0);
  const [count, setCount]         = useState(0);
  const [page, setPage]           = useState(1);
  const [users, setUsers]         = useState([]);
  const [pages, setPages]         = useState([]);
  const [isLoading, setIsLoading] = useState(false);
  const [offset]                  = useState(5);

  const getUsers = () => {
    fetchUsers({ page })
      .then((payload) => {
        setUsers(payload.data.users);
        setNumPages(payload.data.num_pages);
        setCount(payload.data.count);
        initPages();
      }).catch((payload) => {
        console.log(payload.response);
      })
  }

  const initPages = () => {
    let _pages = [];

    let startPage = page;

    if (page - offset <= 0) {
      startPage = 1;
    } else {
      startPage = page - offset;
    }

    let endPage = page + offset;

    if (endPage > numPages) {
      endPage = numPages;
    }

    for (var i = startPage; i <= endPage; i++) {
      _pages.push(i);
    }

    setPages(_pages);
  }

  useEffect(() => {
    getUsers();
  }, [page, numPages]);

  return (
    <React.Fragment>
      <h1>
        Users Index
      </h1>
      <h2>
        Num Pages: {numPages} Count: {count} Page: {page}
      </h2>
      {(() => {
        if (users.length > 0) {
          return (
            <React.Fragment>
              <table className="table table-sm table-bordered">
                <thead>
                  <tr>
                    <th/>
                    <th>
                      Name
                    </th>
                    <th>
                      Username
                    </th>
                    <th>
                      Email
                    </th>
                    <th>
                      Identification Number
                    </th>
                    <th>
                      Roles
                    </th>
                  </tr>
                </thead>
                <tbody>
                  {users.map((user) => {
                    return (
                      <tr key={`user-${user.id}`}>
                        <td>
                        </td>
                        <td>
                          {user.full_name}
                        </td>
                        <td>
                          {user.username}
                        </td>
                        <td>
                          {user.email}
                        </td>
                        <td>
                          {user.identification_number}
                        </td>
                        <td>
                          <ul>
                            {user.roles.filter((role) => { return role != "" }).map((role) => {
                              return (
                                <li key={`user-${user.id}-role-${role}`}>
                                  {role}
                                </li>
                              )
                            })}
                          </ul>
                        </td>
                      </tr>
                    )
                  })}
                </tbody>
              </table>
              <Pagination
                numPages={numPages}
                setNumPages={setNumPages}
                pages={pages}
                setPages={setPages}
                setPage={setPage}
                page={page}
                offset={offset}
              />
            </React.Fragment>
          )
        } else {
          return (
            <p>
              No users found.
            </p>
          )
        }
      })()}
    </React.Fragment>
  )
}
