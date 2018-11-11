import React from 'react';
import $ from 'jquery';

import ReactTable from 'react-table';
import 'react-table/react-table.css';

import SkCubeLoading from '../SkCubeLoading';

import {numberWithCommas} from '../utils/helpers';

export default class BranchLoanProductStatsUI extends React.Component {
  constructor(props) {
    super(props);

    this.state  = {
      isLoading: true,
      dataIsLoading: true,
      branches: [],
      currentBranchId: "",
      data: false
    };
  }

  componentDidMount() {
    this.fetch();
  }

  fetch() {
    var context = this;

    $.ajax({
      url: "/api/v1/branches",
      method: "GET",
      data: {
      },
      dataType: 'json',
      success: function(response) {
        console.log(response);
        var branches        = response.branches;
        var currentBranchId = "";

        if(branches.length > 0) {
          currentBranchId =  branches[0].id;
        }

        context.setState({
          isLoading: false,
          branches: branches,
          currentBranchId: currentBranchId
        });
      },
      error: function(response) {
        console.log(response);
        alert("Error in fetching branches data");

        context.setState({
          isLoading: false,
          dataIsLoading: true,
          data: false,
          branches: [],
          currentBranchId: ""
        });
      }
    });
  }

  handleBranchChanged(event) {
    this.setState({
      currentBranchId: event.target.value
    });
  }

  renderFilter() {
    var context = this;
    var state   = context.state;

    var branchOptions = [];
    
    for(var i = 0; i < state.branches.length; i++) {
      branchOptions.push(
        <option value={state.branches[i].id} key={"b-" + i}>
          {state.branches[i].name}
        </option>
      );
    }

    return (
      <div className="row">
        <div className="col-md-8">
          <div className="form-group">
            <label>Branch</label>
            <select 
              className="form-control" 
              value={this.state.currentBranchId}
              onChange={this.handleBranchChanged.bind(this)}
            >
              {branchOptions}
            </select>
            <br/>
          </div>
        </div>
        <div className="col-md-4">
          <label>Actions</label>
          <br/>
          <button
            className="btn btn-primary btn-block"
          >
            <span className="fa fa-sync"/>
            Generate
          </button>
        </div>
      </div>
    );
  }

  renderResult() {
    var context = this;
    var state   = context.state;

    if(state.dataIsLoading) {
      return  (
        <div>
          Fetching data... 
        </div>
      );
    } else if(!data) {
      return  (
        <div>
          No data found
        </div>
      );
    } else {
      return  (
        <div>
          render
        </div>
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
    } else {
      return  (
        <div>
          {this.renderFilter()}
          {this.renderResult()}
        </div>
      );
    }
  }
}
