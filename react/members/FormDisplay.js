import React from 'react';
import $ from 'jquery';

import ReactTable from 'react-table';
import 'react-table/react-table.css';

import SkCubeLoading from '../SkCubeLoading';

export default class FormDisplay extends React.Component {
  constructor(props) {
    super(props);

    this.state  = {
      isLoading: true,
      formDisabled: false,
      data: false,
      memberId: props.id,
      authenticityToken: props.authenticityToken
    };
  }

  componentDidMount() {
    this.fetch();
  }

  save() {
    var context = this;
    var state   = context.state;

    $.ajax({
      url: "/api/v1/members/save",
      method: "POST",
      data: {
        id: state.memberId,
        authenticity_token: state.authenticityToken
      },
      success: function(response) {
      },
      error: function(response) {
      }
    });
  }

  fetch() {
    var context = this;

    $.ajax({
      url: "/api/v1/members/fetch",
      method: "GET",
      data: {
        id: context.state.memberId
      },
      dataType: 'json',
      success: function(response) {
        context.setState({
          isLoading: false,
          data: response
        });
      },
      error: function(response) {
        console.log(response);
        alert("Error in fetching members data");

        context.setState({
          isLoading: true,
          data: false
        });
      }
    });
  }

  render() {
    var context = this;
    var state   = context.state;

    if(state.isLoading) {
      return  (
        <SkCubeLoading/>
      );
    } else if(state.data != false) {
      return (
        <div>
          <h2>Member Form</h2>
        </div>
      );
    } else {
      <div>
        No data
      </div>
    }
  }
}
