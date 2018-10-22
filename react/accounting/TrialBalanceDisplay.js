import React from 'react';
import $ from 'jquery';

import ReactTable from 'react-table';
import DatePicker from 'react-datepicker';
import Select from 'react-select';
import 'react-table/react-table.css';

import SkCubeLoading from '../SkCubeLoading';

import moment from 'moment';

import 'react-datepicker/dist/react-datepicker.css';

export default class TrialBalanceDisplay extends React.Component {
  constructor(props) {
    super(props);
    
    var date      = new Date();
    var y         = date.getFullYear();
    var m         = date.getMonth();
    var firstDay  = new Date(y, m, 1);
    var lastDay   = new Date(y, m + 1, 0);

    this.state  = {
      isLoading: false,
      start_date: moment(firstDay),
      end_date: moment(lastDay),
      currentBranchId: "",
      branches: [],
      data: false
    };
  }

  componentDidMount() {
    this.fetchBranches();
  }

  numberWithCommas(x) {
    x = (Math.round(x * 100) / 100).toFixed(2);

    if(x < 0) {
      x = x * -1; 
      x = "(" + x.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ",") + ")";
    } else {
      x = x.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ",");
    }   

    return x;

  }

  fetchBranches() {
    var context = this;

    $.ajax({
      url: "/api/v1/branches",
      method: "GET",
      data: {
        
      },
      dataType: 'json',
      success: function(response) {
        context.setState({
          branches: response.branches
        });
      },
      error: function(response) {
        console.log(response);
        alert("Error in fetching branches");

        context.setState({
          branches: []
        });
      }
    });
  }

  fetch() {
    var context     = this;
    var start_date  = moment(context.state.start_date).format('YYYY-MM-DD');
    var end_date    = moment(context.state.end_date).format('YYYY-MM-DD');

    $.ajax({
      url: "/api/v1/accounting/fetch_trial_balance",
      method: "GET",
      data: {
        start_date: start_date,
        end_date: end_date,
        branch_id: context.state.currentBranchId
      },
      dataType: 'json',
      success: function(response) {
        console.log(response);
        var data  = response.data;

        context.setState({
          isLoading: false,
          data: data
        });
      },
      error: function(response) {
        console.log(response);
        alert("Error in fetching trial balance data");

        context.setState({
          isLoading: false,
          data: false
        });
      }
    });
  }

  handleStartDateChanged(o) {
    this.setState({
      start_date: o
    });
  }

  handleEndDateChanged(o) {
    this.setState({
      end_date: o
    });
  }

  handleGenerateClicked() {
    var context = this;
    
    context.setState({
      isLoading: true
    });

    context.fetch();
  }

  renderTable() {
    var context = this;
    var state   = context.state;

    var entries = [];

    for(var i = 0; i < state.data.entries.length; i++) {
      var entry = state.data.entries[i];
      entries.push(
        <tr key={"gl-entry-" + i}>
          <td>
            <strong>
              {entry.name}
            </strong>
          </td>
          <td className="text-right">
            {this.numberWithCommas(entry.beginning_debit)}
          </td>
          <td className="text-right">
            {this.numberWithCommas(entry.beginning_credit)}
          </td>
          <td className="text-right">
            {this.numberWithCommas(entry.current_debit)}
          </td>
          <td className="text-right">
            {this.numberWithCommas(entry.current_credit)}
          </td>
          <td className="text-right">
            {this.numberWithCommas(entry.ending_debit)}
          </td>
          <td className="text-right">
            {this.numberWithCommas(entry.ending_credit)}
          </td>
        </tr>
      );
    }

    if(!state.isLoading && state.data != false) {
      return  (
        <table className="table table-sm table-bordered table-hover">
          <thead>
            <tr>
              <th>
                Accounting Code
              </th>
              <th className="text-right">
                Beginning DR
              </th>
              <th className="text-right">
                Beginning CR
              </th>
              <th className="text-right">
                Current DR
              </th>
              <th className="text-right">
                Current CR
              </th>
              <th className="text-right">
                Ending DR
              </th>
              <th className="text-right">
                Ending CR
              </th>
            </tr>
          </thead>
          <tbody>
            {entries}
          </tbody>
        </table>
      );
    }
  }

  handleBranchChanged(event) {
    this.setState({
      currentBranchId: event.target.value
    });
  }

  renderContent() {
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
      return  (
        <div>
          No data
        </div>
      );
    }
  }

  render() {
    var context = this;
    var state   = context.state;

    var branchOptions = [];
    
    for(var i = 0; i < state.branches.length; i++) {
      branchOptions.push(
        <option value={state.branches[i].id}>
          {state.branches[i].name}
        </option>
      );
    }

    var currentBranchId = state.currentBranchId;

    console.log(branchOptions);
    console.log("currentBranchId: " + this.state.currentBranchId);

    return  (
      <div>
        <div className="row">
          <div className="col">
            <div className="form-group">
              <label>Start Date</label>
              <DatePicker
                className="form-control"
                selected={state.start_date}
                onChange={context.handleStartDateChanged.bind(this)}
                disabled={state.isLoading}
              />
            </div>
          </div>
          <div className="col">
            <div className="form-group">
              <label>End Date</label>
              <DatePicker
                className="form-control"
                selected={state.end_date}
                onChange={context.handleEndDateChanged.bind(this)}
                disabled={state.isLoading}
              />
            </div>
          </div>
          <div className="col">
            <div className="form-group">
              <label>Branch</label>
              <select 
                className="form-control" 
                value={currentBranchId}
                onChange={this.handleBranchChanged.bind(this)}
              >
                {branchOptions}
              </select>
              <br/>
            </div>
          </div>
          <div className="col">
            <div className="form-group">
              <label>Actions</label>
              <br/>
              <button
                className="btn btn-primary"
                onClick={context.handleGenerateClicked.bind(this)}
              >
                <span className="fa fa-sync"/>
                Generate
              </button>
            </div>
          </div>
        </div>
        <hr/> 
        {context.renderContent()}
      </div>
    );
  }
}
