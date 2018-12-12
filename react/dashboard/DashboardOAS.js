import React from 'react';
import $ from 'jquery';
import Select from 'react-select';

import SkCubeLoading from '../SkCubeLoading';
import {numberAsPercent, numberWithCommas} from '../utils/helpers';

export default class DashboardOAS extends React.Component {
  constructor(props) {
    super(props);

    this.state  = {
      currentBranch: {
        id: "",
        name: "",
        centers: []
      },
      branches: [],
      data: {
      },
      isLoading: true
    }
  }

  componentDidMount() {
    var context = this;
    $.ajax({
      url: '/api/v1/dashboard',
      success: function(response) {
        var currentBranch = {
          id: "",
          name: "",
          centers: []
        };

        if(response.branches.length > 0) {
          currentBranch = response.branches[0]; 
        }

        context.setState({
          branches: response.branches,
          currentBranch: currentBranch,
          data: {
            branch_loans_stats: response.branch_loans_stats
          },
          isLoading: false
        });
      },
      error: function(response) {
        console.log(response);
        alert("Error in fetching branches!");
      }
    });
  }

  handleBranchChanged(o) {
    var currentBranch = this.state.currentBranch;

    for(var i = 0; i < this.state.branches.length; i++) {
      if(this.state.branches[i].id == o.value) {
        currentBranch = this.state.branches[i];
      }
    }

    this.setState({
      currentBranch: currentBranch
    });
  }

  handleSyncClicked() {
    var context       = this;
    var currentBranch = this.state.currentBranch;

    context.setState({
      isLoading: true
    });

    $.ajax({
      url: '/api/v1/dashboard',
      method: 'GET',
      data: {
        branch_id: currentBranch.id
      },
      success: function(response) {
        context.setState({
          data: {
            branch_loans_stats: response.branch_loans_stats
          },
          isLoading: false
        });
      },
      error: function(response) {
        console.log(response);
        alert("Error in fetching data!");
      }
    });
  }

  renderControls() {
    var state = this.state;

    var branch  = {
      value: state.currentBranch.id,
      label: state.currentBranch.name
    };

    var branchOptions = []

    for(var i = 0; i < this.state.branches.length; i++) {
      branchOptions.push({
        value: this.state.branches[i].id,
        label: this.state.branches[i].name
      });
    }

    return  (
      <div className="row">
        <div className="col-md-9">
          <div className="form-group">
            <label>
              Branch
            </label>
            <Select
              options={branchOptions}
              onChange={this.handleBranchChanged.bind(this)}
              value={branch}
              disabled={this.state.isLoading}
            />
          </div>
        </div>
        <div className="col-md-3">
          <div className="form-group">
            <label>
              Actions
            </label>
            <br/>
            <div className="btn-group">
              <button
                className="btn btn-primary"
                onClick={this.handleSyncClicked.bind(this)}
                disabled={this.state.isLoading}
              >
                <span className="fa fa-sync"/>
                Sync
              </button>
            </div>
          </div>
        </div>
      </div>
    );
  }

  renderBranchLoansStats() {
    var o = this.state.data.branch_loans_stats;

    if(this.state.isLoading) {
      return  (
        <SkCubeLoading/>
      );
    } else if(!o) {
      return  (
        <p>
          No data found
        </p>
      );
    } else {
      var loanProductRows = [];

      o.data.loan_products.forEach(function(e) {
        loanProductRows.push(
          <tr key={"lp-" + e.loan_product.id}>
            <td>
              <strong>
                {e.loan_product.name}
              </strong>
            </td>
            <td className="text-center">
              {e.num_loans}
            </td>
            <td className="text-right">
              {numberWithCommas(e.total_principal_portfolio)}
            </td>
            <td className="text-right">
              {numberWithCommas(e.total_past_due)}
            </td>
            <td className="text-right">
              {numberWithCommas(e.total_principal_balance)}
            </td>
            <td className="text-center">
              {numberAsPercent(e.par)}
            </td>
            <td className="text-center">
              {numberAsPercent(e.repayment_rate)}
            </td>
          </tr>
        );
      });

      return  (
        <div>
          <h5>
            Loans Stats as of {o.meta.as_of}
          </h5>
          <table className="table table-bordered table-sm table-hover">
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
                  PAR Amount
                </th>
                <th className="text-center">
                  PAR Rate
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
              <tr>
                <th>
                  Total
                </th>
                <th className="text-center">
                  {o.data.num_loans}
                </th>
                <th className="text-right">
                  {numberWithCommas(o.data.total_principal_portfolio)}
                </th>
                <th className="text-right">
                  {numberWithCommas(o.data.total_past_due)}
                </th>
                <th className="text-right">
                  {numberWithCommas(o.data.total_principal_balance)}
                </th>
                <th className="text-center">
                  {numberAsPercent(o.data.par)}
                </th>
                <th className="text-center">
                  {numberAsPercent(o.data.repayment_rate)}
                </th>
              </tr>
            </tfoot>
          </table>
        </div>
      );
    }
  }

  render() {
    return  (
      <div>
        {this.renderControls()}
        {this.renderBranchLoansStats()} 
      </div>
    );
  }
}
