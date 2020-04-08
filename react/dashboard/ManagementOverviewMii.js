import React from 'react';
import $ from 'jquery';

import SkCubeLoading from '../SkCubeLoading';
import {numberAsPercent, numberWithCommas} from '../utils/helpers';

export default class ManagementOverviewMii extends React.Component {
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
      url: '/api/v1/dashboard_mii/overview_mii',
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
        alert("Error in fetching overview mii data");
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
    var colSpan = 13;

    var areaColor     = "#bad5fd";
    var clusterColor  = "#c5ffc1";
    var branchColor   = "#797979";

    var tTotalLife        = 0.00;
    var tTotalRf          = 0.00;
    var tTotalLifeRf      = 0.00;
    var tActiveMembers    = 0;
    var tInforceMembers   = 0;
    var tLapsedMembers    = 0;
    var tPendingMembers   = 0;
    var tDormantMembers   = 0;
    var tResignedActiveMembers = 0;

    for(var i = 0; i < areas.length; i++) {
      rows.push(
        <tr key={"area-" + areas[i].id} style={{backgroundColor: areaColor}}>
          <th className="text-center" colSpan={colSpan}>
            {areas[i].name}
          </th>
        </tr>
      );
     
      var clusters    = areas[i].clusters;

      var aTotalLife        = 0.00;
      var aTotalRf          = 0.00;
      var aTotalLifeRf      = 0.00;
      var aActiveMembers    = 0;
      var aInforceMembers   = 0;
      var aLapsedMembers    = 0;
      var aPendingMembers   = 0;
      var aDormantMembers   = 0;
      var aResignedActiveMembers = 0;

      for(var j = 0; j < clusters.length; j++) {
        rows.push(
          <tr key={"cluster-" + clusters[j].id} style={{backgroundColor: clusterColor}}>
            <th className="text-center" colSpan={colSpan}>
              {clusters[j].name}
            </th>
          </tr>
        );

        var branches  = clusters[j].branches;

        var cTotalLife        = 0.00;
        var cTotalRf          = 0.00;
        var cTotalLifeRf      = 0.00;
        var cActiveMembers    = 0;
        var cInforceMembers   = 0;
        var cLapsedMembers    = 0;
        var cPendingMembers   = 0;
        var cDormantMembers   = 0;
        var cResignedActiveMembers = 0;

        for(var k = 0; k < branches.length; k++) {
          if(k == 0) {
            rows.push(
              <tr key={"header-" + branches[k].id} style={{backgroundColor: branchColor, color: "white"}}>
                <th>
                  Branch Name
                </th>
                <th className="text-center">
                  Inforce
                </th>
                <th className="text-center">
                  Lapsed
                </th>
                <th className="text-center">
                  Pending
                </th>
                <th className="text-center">
                  Dormant
                </th>
                <th className="text-center">
                  Resigned Active
                </th>
                <th className="text-center">
                  Active Members
                </th>
                <th>
                  As Of (Member Count)
                </th>
                <th className="text-center">
                  LIFE
                </th>
                <th className="text-center">
                  RF
                </th>
                <th>
                  As Of (Personal Fund)
                </th>
              </tr>
            );
          }

          cTotalLife        += branches[k].data.total_life
          cTotalRf          += branches[k].data.total_rf
          cActiveMembers    += branches[k].data.active_members.total;
          cInforceMembers   += branches[k].data.inforce_members.total;
          cLapsedMembers    += branches[k].data.lapsed_members.total;
          cPendingMembers   += branches[k].data.pending_members.total;
          cDormantMembers   += branches[k].data.dormant_members.total;
          cResignedActiveMembers += branches[k].data.resigned_active_members.total;

          aTotalLife        += branches[k].data.total_life
          aTotalRf          += branches[k].data.total_rf
          aActiveMembers    += branches[k].data.active_members.total;
          aInforceMembers   += branches[k].data.inforce_members.total;
          aLapsedMembers    += branches[k].data.lapsed_members.total;
          aPendingMembers   += branches[k].data.pending_members.total;
          aDormantMembers   += branches[k].data.dormant_members.total;
          aResignedActiveMembers += branches[k].data.resigned_active_members.total;

          tTotalLife        += branches[k].data.total_life
          tTotalRf          += branches[k].data.total_rf
          tActiveMembers    += branches[k].data.active_members.total;
          tInforceMembers   += branches[k].data.inforce_members.total;
          tLapsedMembers    += branches[k].data.lapsed_members.total;
          tPendingMembers   += branches[k].data.pending_members.total;
          tDormantMembers   += branches[k].data.dormant_members.total;
          tResignedActiveMembers += branches[k].data.resigned_active_members.total;

          rows.push(
            <tr key={"branch-" + branches[k].id}>
              <td>
                <strong>
                  {branches[k].name}
                </strong>
              </td>
              <td className="text-center">
                {branches[k].data.inforce_members.total}
              </td>
              <td className="text-center">
                {branches[k].data.lapsed_members.total}
              </td>
              <td className="text-center">
                {branches[k].data.pending_members.total}
              </td>
              <td className="text-center">
                {branches[k].data.dormant_members.total}
              </td>
              <td className="text-center">
                {branches[k].data.resigned_active_members.total}
              </td>
              <td className="text-center">
                {branches[k].data.active_members.total}
              </td>
              <td className="text-center">
                {branches[k].data.member_counts_as_of}
              </td>
              <td className="text-center">
                {numberWithCommas(branches[k].data.total_life)}
              </td>
              <td className="text-center">
                {numberWithCommas(branches[k].data.total_rf)}
              </td>
              <td className="text-center">
                {branches[k].data.personal_funds_as_of}
              </td>
            </tr>
          );
        }

        rows.push(
          <tr key={"cluster-total-" + clusters[j].id} style={{backgroundColor: clusterColor}}>
            <td>
              <strong>
                {clusters[j].name} Total
              </strong>
            </td>
            <td className="text-center">
              <strong>
                {cInforceMembers}
              </strong>
            </td>
            <td className="text-center">
              <strong>
                {cLapsedMembers}
              </strong>
            </td>
            <td className="text-center">
              <strong>
                {cPendingMembers}
              </strong>
            </td>
            <td className="text-center">
              <strong>
                {cDormantMembers}
              </strong>
            </td>
            <td className="text-center">
              <strong>
                {cResignedActiveMembers}
              </strong>
            </td>
            <td className="text-center">
              <strong>
                {cActiveMembers}
              </strong>
            </td>
            <td>
            </td>
            <td className="text-center">
              <strong>
                {numberWithCommas(cTotalLife)}
              </strong>
            </td>
            <td className="text-center">
              <strong>
                {numberWithCommas(cTotalRf)}
              </strong>
            </td>
            <td>
            </td>
          </tr>
        );
      }

      rows.push(
        <tr key={"area-total-" + areas[i].id} style={{backgroundColor: areaColor}}>
          <td>
            <strong>
              {areas[i].name} Total
            </strong>
          </td>
          <td className="text-center">
            <strong>
              {aInforceMembers}
            </strong>
          </td>
          <td className="text-center">
            <strong>
              {aLapsedMembers}
            </strong>
          </td>
          <td className="text-center">
            <strong>
              {aPendingMembers}
            </strong>
          </td>
          <td className="text-center">
            <strong>
              {aDormantMembers}
            </strong>
          </td>
          <td className="text-center">
            <strong>
              {aResignedActiveMembers}
            </strong>
          </td>
          <td className="text-center">
            <strong>
              {aActiveMembers}
            </strong>
          </td>
          <td>
          </td>
          <td className="text-center">
            <strong>
              {numberWithCommas(aTotalLife)}
            </strong>
          </td>
          <td className="text-center">
            <strong>
              {numberWithCommas(aTotalRf)}
            </strong>
          </td>
          <td>
          </td>
        </tr>
      );
    }


    rows.push(
      <tr key={"grand-total"} style={{backgroundColor: "#000", color: "#fff"}}>
        <td>
          <strong>
            Grand Total
          </strong>
        </td>
        <td className="text-center">
          <strong>
            {tInforceMembers}
          </strong>
        </td>
        <td className="text-center">
          <strong>
            {tLapsedMembers}
          </strong>
        </td>
        <td className="text-center">
          <strong>
            {tPendingMembers}
          </strong>
        </td>
        <td className="text-center">
          <strong>
            {tDormantMembers}
          </strong>
        </td>
        <td className="text-center">
          <strong>
            {tResignedActiveMembers}
          </strong>
        </td>
        <td className="text-center">
          <strong>
            {tActiveMembers}
          </strong>
        </td>
        <td>
        </td>
        <td className="text-center">
          <strong>
            {numberWithCommas(tTotalLife)}
          </strong>
        </td>
        <td className="text-center">
          <strong>
            {numberWithCommas(tTotalRf)}
          </strong>
        </td>
        <td>
        </td>
      </tr>
    );

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
            <div className="col-md-10 col-xs-12">
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
            <div className="col-md-2 col-xs-12">
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
