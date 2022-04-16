import React from 'react';
import $ from 'jquery';

import ReactTable from 'react-table';
import DatePicker from 'react-datepicker';
import Select from 'react-select';

import SkCubeLoading from '../SkCubeLoading';

import moment from 'moment';

import 'react-datepicker/dist/react-datepicker.css';

import {numberWithCommas} from '../utils/helpers';

export default class TrialBalanceComponent extends React.Component {
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
      currentAccountingFundId: "",
      branches: [],
      accountingFunds: JSON.parse(props.accountingFunds),
      data: false
    };
  }

  componentDidMount() {
    this.fetchBranches();

    if(this.state.accountingFunds.length > 0) {
      this.setState({
        currentAccountingFundId: this.state.accountingFunds[0].id
      });
    }
  }

  fetchBranches() {
    var context = this;

    $.ajax({
      url: "/api/v1/branches",
      method: "GET",
      data: {
        b: true        
      },
      dataType: 'json',
      success: function(response) {
        context.setState({
          branches: response.branches,
          currentBranchId: response.branches[0].id
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
        branch_id: context.state.currentBranchId,
        accounting_fund_id: context.state.currentAccountingFundId
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

        var errors  = JSON.parse(response.responseText).errors;

        for(var i = 0; i < errors.length; i++) {
          alert(errors[i]);
        }

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

  handlePrintClicked() {
    var context = this;
    
    context.setState({
      isLoading: true
    });

    var type        = "trial_balance";
    var start_date  = moment(context.state.start_date).format('YYYY-MM-DD');
    var end_date    = moment(context.state.end_date).format('YYYY-MM-DD');
    var branch_id   = context.state.currentBranchId;

    context.setState({
      isLoading: false
    });

    window.open("/print?start_date=" + start_date + "&end_date=" + end_date + "&type=" + type + "&branch_id=" + branch_id);
  }

  handleExcelClicked() {
    var context = this;
    
    context.setState({
      isLoading: true
    });

    var start_date  = moment(context.state.start_date).format('YYYY-MM-DD');
    var end_date    = moment(context.state.end_date).format('YYYY-MM-DD');

    $.ajax({
      url: "/api/v1/accounting/trial_balance_excel",
      method: 'GET',
      data: { 
        start_date: start_date,
        end_date: end_date,
        branch_id: context.state.currentBranchId,
        accounting_fund_id: context.state.currentAccountingFundId,
        authenticity_token: context.props.authenticityToken
      },
      dataType: 'json',
      success: function(response) {
        console.log(response);
        var data  = response.data;
        var filename = response.filename;

        context.setState({
          isLoading: false,
          data: data
        });

        window.location.href = "/download_file?filename=" + filename;
      },
      error: function(response) {
        console.log(response);
        alert("Error generating excel!");

        var errors  = JSON.parse(response.responseText).errors;

        for(var i = 0; i < errors.length; i++) {
          alert(errors[i]);
        }

        context.setState({
          isLoading: false,
          data: false
        });
      }
    });
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
              {entry.code}
            </strong>
          </td>
          <td>
            <strong>
              {entry.name} 
            </strong>
          </td>
          <td className="text-end">
            {numberWithCommas(entry.beginning_debit)}
          </td>
          <td className="text-end">
            {numberWithCommas(entry.beginning_credit)}
          </td>
          <td className="text-end">
            {numberWithCommas(entry.current_debit)}
          </td>
          <td className="text-end">
            {numberWithCommas(entry.current_credit)}
          </td>
          <td className="text-end">
            {numberWithCommas(entry.ending_debit)}
          </td>
          <td className="text-end">
            {numberWithCommas(entry.ending_credit)}
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
              <th>
                Accounting Name
              </th>
              <th className="text-end">
                Beginning DR
              </th>
              <th className="text-end">
                Beginning CR
              </th>
              <th className="text-end">
                Current DR
              </th>
              <th className="text-end">
                Current CR
              </th>
              <th className="text-end">
                Ending DR
              </th>
              <th className="text-end">
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

  handleAccountingFundChanged(event) {
    this.setState({
      currentAccountingFundId: event.target.value
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
        <option value={state.branches[i].id} key={"branch-" + i}>
          {state.branches[i].name}
        </option>
      );
    }

    var accountingFundOptions = [];

    accountingFundOptions.push(
      <option value={""} key={"acc-fund-all"}>
        -- SELECT ALL --
      </option>
    );

    console.log(state.accountingFunds);

    for(var i = 0; i < state.accountingFunds.length; i++) {
      accountingFundOptions.push(
        <option value={state.accountingFunds[i].id} key={"acc-fund-" + i}>
          {state.accountingFunds[i].name}
        </option>
      );
    }

    var currentBranchId         = state.currentBranchId;
    var currentAccountingFundId = state.currentAccountingFundId;

    return  (
      <div>
        <div className="row">
          <div className="col">
            <div className="form-group">
              <label>Start Date</label>
              <br/>
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
              <br/>
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
              <label>Accounting Fund</label>
              <select 
                className="form-control" 
                value={currentAccountingFundId}
                onChange={this.handleAccountingFundChanged.bind(this)}
              >
                {accountingFundOptions}
              </select>
              <br/>
            </div>
          </div>
          <div className="col">
            <div className="form-group">
              <label>Actions</label>
              <br/>
              <div className="btn-group">
                <button
                  className="btn btn-primary"
                  onClick={context.handleGenerateClicked.bind(this)}
                  disabled={state.isLoading}
                >
                  <span className="fa fa-sync"/>
                  Generate
                </button>
                <button
                  className="btn btn-info"
                  onClick={context.handlePrintClicked.bind(this)}
                  disabled={state.isLoading}
                >
                  <span className="fa fa-print"/>
                  Print
                </button>
                <button
                  className="btn btn-secondary"
                  onClick={context.handleExcelClicked.bind(this)}
                  disabled={state.isLoading}
                >
                  <span className="fa fa-print"/>
                  Excel
                </button>
              </div>
            </div>
          </div>
        </div>
        <hr/> 
        {context.renderContent()}
      </div>
    );
  }
}
