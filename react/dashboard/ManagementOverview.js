import React from 'react';
import $ from 'jquery';

import SkCubeLoading from '../SkCubeLoading';
import {numberAsPercent, numberWithCommas} from '../utils/helpers';

export default class ManagementOverview extends React.Component {
  constructor(props) {
    super(props);

    this.state  = {
      isLoading: true,
      isFetching: false,
      data: false,
      asOf: "",
    }
  }

  componentDidMount() {
    this.fetch();
  }

  fetch() {
    var context = this;

    $.ajax({
      method: 'GET',
      url: '/api/v1/dashboard/overview',
      data: {
        as_of: context.state.asOf
      },
      success: function(response) {
        console.log(response);

        context.setState({
          isLoading: false,
          isFetching: false,
          data: response
        });
      },
      error: function(response) {
        console.log(response);
        alert("Error in fetching overview data");
      }
    });
  }

  handleSyncClicked() {
    this.setState({
      isFetching: true
    });

    this.fetch();
  }

  handleAsOfChanged(event) {
    this.setState({
      asOf: event.target.value
    });
  }

  renderOverviewTable() {
    var areas   = this.state.data.areas;
    var rows    = [];
    var colSpan = 11;

    var areaColor     = "#bad5fd";
    var clusterColor  = "#c5ffc1";
    var branchColor   = "#797979";

    for(var i = 0; i < areas.length; i++) {
      rows.push(
        <tr key={"area-" + areas[i].id} style={{backgroundColor: areaColor}}>
          <th className="text-center" colSpan={colSpan}>
            {areas[i].name}
          </th>
        </tr>
      );
     
      var clusters    = areas[i].clusters;

      for(var j = 0; j < clusters.length; j++) {
        rows.push(
          <tr key={"cluster-" + clusters[j].id} style={{backgroundColor: clusterColor}}>
            <th className="text-center" colSpan={colSpan}>
              {clusters[j].name}
            </th>
          </tr>
        );

        var branches  = clusters[j].branches;

        var cPrincipal      = 0.00;
        var cPrincipalPaid  = 0.00;
        var cPortfolio      = 0.00;
        var cPastDueAmount  = 0.00;
        var cParAmount      = 0.00;
        var cPureSavers     = 0;
        var cActiveLoaners  = 0;
        var cActiveMembers  = 0;

        for(var k = 0; k < branches.length; k++) {
          if(k == 0) {
            rows.push(
              <tr key={"header-" + branches[k].id} style={{backgroundColor: branchColor, color: "white"}}>
                <th>
                  Branch Name
                </th>
                <th className="text-right">
                  Principal
                </th>
                <th className="text-right">
                  Principal Paid
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
                <th>
                  As Of
                </th>
                <th className="text-center">
                  Pure Savers
                </th>
                <th className="text-center">
                  Active Loaners
                </th>
                <th className="text-center">
                  Active Members
                </th>
                <th>
                  As Of (Member Counts)
                </th>
              </tr>
            );
          }

          cPrincipal      += branches[k].data.principal;
          cPrincipalPaid  += branches[k].data.principal_paid;
          cPortfolio      += branches[k].data.portfolio;
          cPastDueAmount  += branches[k].data.principal_balance;
          cParAmount      += branches[k].data.par_amount;
          cPureSavers     += branches[k].data.pure_savers.total;
          cActiveLoaners  += branches[k].data.loaners.total;
          cActiveMembers  += branches[k].data.active_members.total;

          rows.push(
            <tr key={"branch-" + branches[k].id}>
              <td>
                <strong>
                  {branches[k].name}
                </strong>
              </td>
              <td className="text-right">
                {numberWithCommas(branches[k].data.principal)}
              </td>
              <td className="text-right">
                {numberWithCommas(branches[k].data.principal_paid)}
              </td>
              <td className="text-right">
                {numberWithCommas(branches[k].data.portfolio)}
              </td>
              <td className="text-right">
                {numberWithCommas(branches[k].data.principal_balance)}
              </td>
              <td className="text-right">
                {numberWithCommas(branches[k].data.par_amount)}
              </td>
              <td>
                {branches[k].data.as_of}
              </td>
              <td className="text-center">
                {branches[k].data.pure_savers.total}
              </td>
              <td className="text-center">
                {branches[k].data.loaners.total}
              </td>
              <td className="text-center">
                {branches[k].data.active_members.total}
              </td>
              <td>
                {branches[k].data.member_counts_as_of}
              </td>
            </tr>
          );
        }

        // Cluster level total
        rows.push(
          <tr key={"cluster-total-" + clusters[j].id} style={{backgroundColor: clusterColor}}>
            <td>
              <strong>
                {clusters[j].name} Total
              </strong>
            </td>
            <td className="text-right">
              <strong>
                {numberWithCommas(cPrincipal)}
              </strong>
            </td>
            <td className="text-right">
              <strong>
                {numberWithCommas(cPrincipalPaid)}
              </strong>
            </td>
            <td className="text-right">
              <strong>
                {numberWithCommas(cPortfolio)}
              </strong>
            </td>
            <td className="text-right">
              <strong>
                {numberWithCommas(cPastDueAmount)}
              </strong>
            </td>
            <td className="text-right">
              <strong>
                {numberWithCommas(cParAmount)}
              </strong>
            </td>
            <td className="text-right">
            </td>
            <td className="text-center">
              <strong>
                {cPureSavers}
              </strong>
            </td>
            <td className="text-center">
              <strong>
                {cActiveLoaners}
              </strong>
            </td>
            <td className="text-center">
              <strong>
                {cActiveMembers}
              </strong>
            </td>
            <td>
            </td>
          </tr>
        );
      }
    }

    return (
      <table className="table table-sm table-bordered">
        <tbody>
          {rows}
        </tbody>
      </table>
    );
  }

  render() {
    if(this.state.isLoading) {
      return (
        <div>
          <SkCubeLoading/>
          <center>
            <h6>
              Loading Overview...
            </h6>
          </center>
        </div>
      );
    } else {
      return (
        <div>
          <h4>
            Overview
          </h4>
          <div className="row">
            <div className="col-md-9 col-xs-12">
              <div className="form-group">
                <input
                  type="date"
                  className="form-control"
                  disabled={this.state.isFetching}
                  value={this.state.asOf}
                  onChange={this.handleAsOfChanged.bind(this)}
                />
              </div>
            </div>
            <div className="col-md-3 col-xs-12">
              <div className="form-group">
                <button 
                  className="btn btn-info btn-block"
                  disabled={this.state.isFetching}
                  onClick={this.handleSyncClicked.bind(this)}
                >
                  <span className="fa fa-sync"/>
                  Sync
                </button>
              </div>
            </div>
          </div>
          {this.renderOverviewTable()}
        </div>
      );
    }
  }
}
