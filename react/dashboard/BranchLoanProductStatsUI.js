import React from 'react';
import $ from 'jquery';

import ReactTable from 'react-table';
import 'react-table/react-table.css';

import SkCubeLoading from '../SkCubeLoading';

import {numberWithCommas, numberAsPercent} from '../utils/helpers';

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

  fetchData() {
    var context         = this;
    var state           = context.state;
    var currentBranchId = state.currentBranchId;

    if(state.currentBranchId) {
      $.ajax({
        url: "/api/v1/branches/" + state.currentBranchId + "/stats",
        method: 'GET',
        data: {
        },
        success: function(response) {
          context.setState({
            data: response,
            dataIsLoading: false,
            isLoading: false
          });
        },
        error: function(respones) {
          context.setState({
            data: false,
            dataIsLoading: false,
            isLoading: false
          });
        }
      });
    } else {
      context.setState({
        data: false,
        dataIsLoading: false
      });
    }
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
        var dataIsLoading   = true;

        if(branches.length > 0) {
          currentBranchId = branches[0].id;
        }

        context.setState({
          isLoading: false,
          branches: branches,
          dataIsLoading: dataIsLoading,
          currentBranchId: currentBranchId
        });

        context.fetchData();
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
    var data    = state.data;

    if(state.dataIsLoading == true) {
      return  (
        <div>
          <SkCubeLoading/>
          <center>
            Fetching data... 
          </center>
        </div>
      );
    } else if(state.dataIsLoading != true && state.data == false) {
      return  (
        <div>
          No data found
        </div>
      );
    } else {
      var loanProductRows = [];
      var data            = context.state.data;

      for(var i = 0; i < data.loan_products.length; i++) {
        var loanProduct = data.loan_products[i].loan_product.name;
        var activeLoans = data.loan_products[i].num_loans;
        var portfolio   = numberWithCommas(data.loan_products[i].total_principal_portfolio);
        var pastDueAmt  = numberWithCommas(data.loan_products[i].total_past_due);
        var parAmt      = numberWithCommas(data.loan_products[i].total_principal_balance);
        var parRate     = numberAsPercent(data.loan_products[i].par);
        var rr          = numberAsPercent(data.loan_products[i].repayment_rate);

        loanProductRows.push(
          <tr key={"row-" + i}>
            <td>
              <strong>
                {loanProduct}
              </strong>
            </td>
            <td>
              <center>
                {activeLoans}
              </center>
            </td>
            <td className="text-right">
              <div className="text-muted">
                <strong>
                  {portfolio}
                </strong>
              </div>
            </td>
            <td className="text-right">
              <strong>
                {pastDueAmt}
              </strong>
            </td>
            <td className="text-right">
              <strong>
                {parAmt}
              </strong>
            </td>
            <td className="text-center">
              {parRate}
            </td>
            <td className="text-center">
              {rr}
            </td>
          </tr>
        );
      }

      return  (
        <div>
          <table className="table table-sm table-bordered table-hover">
            <thead>
              <tr>
                <th>
                  Loan Product
                </th>
                <th className="text-center">
                  Active Loans
                </th>
                <th className="text-right">
                  Portfolio
                </th>
                <th className="text-right">
                  Past Due Amount
                </th>
                <th className="text-right">
                  Par Amount
                </th>
                <th className="text-center">
                  Par Rate
                </th>
                <th className="text-center">
                  RR
                </th>
              </tr>
            </thead>
            <tbody>
              {loanProductRows}
            </tbody>
            <tfoot>
              <tr key={"total-row"}>
                <td>
                  <strong>
                    Total
                  </strong>
                </td>
                <td className="text-center">
                  <strong>
                    {data.num_loans}
                  </strong>
                </td>
                <td className="text-right">
                  <strong>
                    {numberWithCommas(data.total_principal_portfolio)}
                  </strong>
                </td>
                <td className="text-right">
                  <strong>
                    {numberWithCommas(data.total_past_due)}
                  </strong>
                </td>
                <td className="text-right">
                  <strong>
                    {numberWithCommas(data.total_principal_balance)}
                  </strong>
                </td>
                <td className="text-center">
                  <strong>
                    {numberAsPercent(data.par)}
                  </strong>
                </td>
                <td className="text-center">
                  <strong>
                    {numberAsPercent(data.repayment_rate)}
                  </strong>
                </td>
              </tr>
            </tfoot>
          </table>
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
