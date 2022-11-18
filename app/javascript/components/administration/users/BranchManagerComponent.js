import React from 'react';
import $ from 'jquery';
import Toggle from 'react-toggle';
import "react-toggle/style.css";

import SkCubeLoading from '../../SkCubeLoading';

export default class BranchManagerComponent extends React.Component {
  constructor(props) {
    super(props);

    this.state  = {
      userBranches: [],
      isLoading: true
    }
  }

  componentWillMount() {
    this.fetchUserBranches();
  }

  fetchUserBranches() {
    var url     = "/api/v1/administration/user_branches"
    var context = this;

    $.ajax({
      url: url,
      method: 'GET',
      data: {
        id: context.props.id
      },
      success: function(response) {
        context.setState({
          isLoading: false,
          userBranches: response.user_branches
        });
      },
      error: function(response) {
        console.log(response);
        alert("Error in fetching user branches");
      }
    });
  }

  handleToggled(id, event) {
    var context = this;

    $.ajax({
      url: "/api/v1/administration/user_branches/toggle",
      method: 'POST',
      data: {
        id: id,
        authenticity_token: context.props.authenticityToken
      },
      success: function(response) {
        context.setState({
          userBranches: response.user_branches
        });
      },
      error: function(response) {
        console.log(response);
        alert("Cannot toggle branch");
      }
    });
  }

  renderBranches() {
    var userBranches  = this.state.userBranches;

    var userBranchRecords = [];

    for(var i = 0; i < userBranches.length; i++) {
      userBranchRecords.push(
        <tr key={"user-branch-" + userBranches[i].id}>
          <td>
            {userBranches[i].branch.name}
          </td>
          <td>
            <center>
              <Toggle
                defaultChecked={userBranches[i].active}
                onChange={this.handleToggled.bind(this, userBranches[i].id)}
              />
            </center>
          </td>
        </tr>
      );
    }

    return (
      <table className="table table-hover table-sm table-bordered">
        <thead>
          <tr>
            <th>Branch</th>
            <th>
              <center>
                Actions
              </center>
            </th>
          </tr>
        </thead>
        <tbody>
          {userBranchRecords}
        </tbody>
      </table>
    );
  }

  render() {
    var context = this;
    var state   = context.state;

    if(state.isLoading) {
      return (
        <SkCubeLoading/>
      );
    } else {
      return (
        <div>
          {this.renderBranches()}
        </div>
      );
    }
  }
}
