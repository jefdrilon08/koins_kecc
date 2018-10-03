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

    this.state  = {
      isLoading: false,
      start_date: moment(),
      end_date: moment(),
      data: false
    };
  }

  componentDidMount() {
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

  fetch() {
    var context     = this;
    console.log(context.state);
    var start_date  = moment(context.state.start_date).format('YYYY-MM-DD');
    var end_date    = moment(context.state.end_date).format('YYYY-MM-DD');

    $.ajax({
      url: "/api/v1/accounting/fetch_trial_balance",
      method: "GET",
      data: {
        start_date: start_date,
        end_date: end_date
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
        alert("Error in fetching savings data");

        context.setState({
          isLoading: true,
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

    if(!state.isLoading && state.data != false) {
      return  (
        <ReactTable
          columns={[
            {
              Header: "Accounting Code",
              accessor: "name",
              Cell: row => (
                <strong>
                  {row.original.name}
                </strong>
              )
            },
            {
              Header: "Beginning DR",
              accessor: "beginning_debit",
              Cell: row => (
                <div className="text-right">
                  {context.numberWithCommas(row.original.beginning_debit)}
                </div>
              )
            },
            {
              Header: "Beginning CR",
              accessor: "beginning_credit",
              Cell: row => (
                <div className="text-right">
                  {context.numberWithCommas(row.original.beginning_credit)}
                </div>
              )
            },
            {
              Header: "Current DR",
              accessor: "current_debit",
              Cell: row => (
                <div className="text-right">
                  {context.numberWithCommas(row.original.current_debit)}
                </div>
              )
            },
            {
              Header: "Current CR",
              accessor: "current_credit",
              Cell: row => (
                <div className="text-right">
                  {context.numberWithCommas(row.original.current_credit)}
                </div>
              )
            },
            {
              Header: "Ending DR",
              accessor: "ending_debit",
              Cell: row => (
                <div className="text-right">
                  {context.numberWithCommas(row.original.ending_debit)}
                </div>
              )
            },
            {
              Header: "Ending CR",
              accessor: "ending_credit",
              Cell: row => (
                <div className="text-right">
                  {context.numberWithCommas(row.original.ending_credit)}
                </div>
              )
            }
          ]}
          data={state.data.entries}
        />
      );
    }
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

    return  (
      <div>
        <div className="row">
          <div className="col">
            <div className="form-group">
              <label>Start Date</label>
              <DatePicker
                lassName="form-control"
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
                lassName="form-control"
                selected={state.end_date}
                onChange={context.handleEndDateChanged.bind(this)}
                disabled={state.isLoading}
              />
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
