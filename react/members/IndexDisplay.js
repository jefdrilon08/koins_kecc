import React from 'react';
import $ from 'jquery';

import ReactTable from 'react-table';
import 'react-table/react-table.css';

import SkCubeLoading from '../SkCubeLoading';

export default class IndexDisplay extends React.Component {
  constructor(props) {
    super(props);

    this.state  = {
      isLoading: true,
      data: false
    };
  }

  componentDidMount() {
    this.fetch();
  }

  fetch() {
    var context = this;

    $.ajax({
      url: "/api/v1/members",
      method: "GET",
      data: {
      },
      dataType: 'json',
      success: function(response) {
        var members = response.members;
        console.log(response);

        context.setState({
          isLoading: false,
          data: members
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

  renderTable() {
    var context = this;
    var state   = context.state;

    if(!state.isLoading && state.data != false) {
      return  (
        <ReactTable
          columns={[
            {
              Header: "Name",
              accessor: "name",
              Cell: row => (
                <strong>
                  {row.original.name}
                </strong>
              )
            }
          ]}
          data={state.data}
        />
      );
    }
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
          {context.renderTable()}
        </div>
      );
    } else {
      <div>
        No data
      </div>
    }
  }
}
