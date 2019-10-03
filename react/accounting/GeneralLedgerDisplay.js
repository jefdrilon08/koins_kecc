import React from 'react';
import $ from 'jquery';

import ReactTable from 'react-table';
import DatePicker from 'react-datepicker';
import Select from 'react-select';
import 'react-table/react-table.css';

import SkCubeLoading from '../SkCubeLoading';
import GeneralLedgerEntry from './GeneralLedgerEntry';
import ErrorDisplay from '../ErrorDisplay';

import moment from 'moment';

import 'react-datepicker/dist/react-datepicker.css';

import AccountingCodeMultiSelect from './AccountingCodeMultiSelect';

export default class GeneralLedgerDisplay extends React.Component {
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
      accountingCodeIds: [],
      errors: false,
      data: false
    };
  }

  componentDidMount() {
    this.fetchBranches();
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
        console.log("response from /api/v1/branches");
        console.log(response);
        var branchId  = context.state.currentBranchId;

        if(!branchId) {
          branchId = response.branches[0].id;
        }

        console.log("branchId: " + branchId);

        context.setState({
          branches: response.branches,
          currentBranchId: branchId,
          errors: false
        });
      },
      error: function(response) {
        console.log(response);
        //alert("Error in fetching branches");

        context.setState({
          branches: []
        });
      }
    });
  }

  fetch() {
    var context           = this;
    var start_date        = moment(context.state.start_date).format('YYYY-MM-DD');
    var end_date          = moment(context.state.end_date).format('YYYY-MM-DD');
    var branchId          = context.state.currentBranchId;
    var accountingCodeIds = context.state.accountingCodeIds;

    $.ajax({
      url: "/api/v1/accounting/fetch_general_ledger",
      method: "GET",
      data: {
        start_date: start_date,
        end_date: end_date,
        branch_id: branchId,
        accounting_code_ids: accountingCodeIds
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
        //alert("Error in fetching general ledger data");

        var errors  = JSON.parse(response.responseText);
        console.log(errors);

        context.setState({
          isLoading: false,
          data: false,
          errors: errors
        });
      }
    });
  }
   DownloadExcel() {
    var context           = this;
    var start_date        = moment(context.state.start_date).format('YYYY-MM-DD');
    var end_date          = moment(context.state.end_date).format('YYYY-MM-DD');
    var branchId          = context.state.currentBranchId;
    var accountingCodeIds = context.state.accountingCodeIds;

    $.ajax({
      url: "/accounting/general_ledger_excel_url",
      method: "GET",
      data: {
        start_date: start_date,
        end_date: end_date,
        branch_id: branchId,
        accounting_code_ids: accountingCodeIds
      },
      dataType: 'json',
      success: function(response) {
        window.open(response.download_url,"_blank")
        console.log(response);
        var data  = response.data;
        context.setState({
          isLoading: false,
        });
      },
      error: function(response) {
        console.log(response);
        //alert("Error in fetching general ledger data");

        var errors  = JSON.parse(response.responseText);
        console.log(errors);

        context.setState({
          isLoading: false,
          data: false,
          errors: errors
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

handleDownloadClicked() {
    var context = this;
    
    context.setState({
      isLoading: true
    });

    context.DownloadExcel();
  }


  handlePrintClicked() {
    var context = this;
    
    context.setState({
      isLoading: true
    });

    var start_date        = moment(context.state.start_date).format('YYYY-MM-DD');
    var end_date          = moment(context.state.end_date).format('YYYY-MM-DD');
    var branchId          = context.state.currentBranchId;
    var accountingCodeIds = context.state.accountingCodeIds;

    $.ajax({
      url: "/api/v1/print/generate_file",
      method: 'POST',
      data: { 
        start_date: start_date,
        end_date: end_date,
        branch_id: context.state.currentBranchId,
        accounting_code_ids: accountingCodeIds,
        type: "general_ledger",
        authenticity_token: context.props.authenticityToken
      },
      success: function(response) {
        window.open("/print?filename=" + response.filename, '_blank');

        context.setState({
          isLoading: false
        });
      },
      error: function(response) {
        console.log(response);
        alert("Error in printing!");

        context.setState({
          isLoading: false
        });
      }
    });
  }

  renderTable() {
    var context = this;
    var state   = context.state;


    if(!state.isLoading && state.data != false) {
      var generalLedgerEntries  = state.data.entries;
      console.log("generalLedgerEntries:");
      console.log(generalLedgerEntries);

      var generalLedgerComponents = [];

      for(var i = 0; i < generalLedgerEntries.length; i++) {

        generalLedgerComponents.push(
          <div>
            <GeneralLedgerEntry
              data={generalLedgerEntries[i]}
              key={"glc-" + i}
            />
          </div>
        );
      }

      return  (
        <div>
          {generalLedgerComponents}
        </div>
      );
    }
  }

  renderErrors() {
    if(this.state.errors) {
      return (
        <ErrorDisplay
          errors={this.state.errors}
        />
      );
    }
  }

  renderContent() {
    var context = this;
    var state   = context.state;

    var startDate = state.start_date.format('YYYY-MM-DD');
    var endDate   = state.end_date.format('YYYY-MM-DD');

    if(state.isLoading) {
      return  (
        <SkCubeLoading/>
      );
    } else if(state.data != false) {
      return (
        <div>
          <div className="row">
            <div className="col">
              <h6>
                General Ledger {startDate} to {endDate}
              </h6>
            </div>
          </div>
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

  handleBranchChanged(event) {
    this.setState({
      currentBranchId: event.target.value
    });
  }

  handleAccountingCodeSelectChanged(o) {
    console.log("AccountingCodeMultiSelect.handleAccountingCodeSelectChanged:");
    console.log(o);

    var accountingCodeIds = [];

    for(var i = 0; i < o.length; i++) {
      accountingCodeIds.push(o[i].value);
    }

    this.setState({
      accountingCodeIds: accountingCodeIds
    });
  }

  render() {
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

    var currentBranchId = state.currentBranchId;

    console.log(branchOptions);
    console.log("currentBranchId: " + this.state.currentBranchId);

    return  (
      <div>
        <div className="row">
          <div className="col-md-2">
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
          <div className="col-md-2">
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
          <div className="col-md-2">
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
              <label>Acc. Codes</label>
              <AccountingCodeMultiSelect
                handleAccountingCodeSelectChanged={this.handleAccountingCodeSelectChanged.bind(this)}
              />
            </div>
          </div>
          <div className="col-md-2">
            <div className="form-group">
              <label>Actions</label>
              <br/>
              <div className="btn-group">
                <button
                  className="btn btn-primary"
                  onClick={context.handleGenerateClicked.bind(this)}
                  disabled={this.state.isLoading}
                >
                  <span className="fa fa-sync"/>
                  
                </button>
                <button
                  className="btn btn-info"
                  onClick={context.handlePrintClicked.bind(this)}
                  disabled={this.state.isLoading}
                >
                  <span className="fa fa-print"/>
                  
                </button>
                  <button
                  className="btn btn-success"
                  onClick={context.handleDownloadClicked.bind(this)}
                  disabled={this.state.isLoading}
                >
                  <span className="fa fa-download"/>
                  
                </button>

              </div>
            </div>
          </div>
        </div>
        {this.renderErrors()} 
        <hr/> 
        {context.renderContent()}
      </div>
    );
  }
}
