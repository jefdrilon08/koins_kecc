import React from 'react';
import $ from 'jquery';
import Select from 'react-select';
import Modal from 'react-modal';

import SkCubeLoading from '../SkCubeLoading';
import {numberAsPercent, numberWithCommas} from '../utils/helpers';

const customStyles = {
  content : {
    top                   : '50%',
    left                  : '50%',
    right                 : 'auto',
    bottom                : 'auto',
    marginRight           : '-50%',
    transform             : 'translate(-50%, -50%)',
    height                : '50%',
    overlfow              : 'scroll'
  }
};

Modal.setAppElement('#dashboard-content');

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
      centers: [],
      data: {
      },
      currentMemberList: [],
      isLoading: true,
      modalCycleCountSummaryIsOpen: false
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

        console.log(response);

        context.setState({
          branches: response.branches,
          currentBranch: currentBranch,
          data: {
            branch_loans_stats: response.branch_loans_stats,
            member_counts: response.member_counts,
            watchlist: response.watchlist,
            centers: response.centers,
            cycle_count_summary: response.cycle_count_summary
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

  closeCycleCountSummaryModal() {
    this.setState({
      modalCycleCountSummaryIsOpen: false
    });
  }

  openCycleCountSummaryModal() {
    this.setState({
      modalCycleCountSummaryIsOpen: true
    });
  }

  handleCycleCountClicked(loanProductId, cycle) {
    var o = this.state.data.cycle_count_summary;

    var members = [];

    for(var i = 0; i < o.records.length; i++) {
      for(var j = 0; j < o.records[i].loan_products.length; j++) {
        if(o.records[i].loan_products[j].id == loanProductId && o.records[i].cycle == cycle) {
          for(var k = 0; k < o.records[i].loan_products[j].records.length; k++) {
            members.push(o.records[i].loan_products[j].records[k]);
          }
        }
      }
    }

    this.setState({
      currentMemberList: members
    });

    console.log(members);

    this.openCycleCountSummaryModal();
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
            branch_loans_stats: response.branch_loans_stats,
            member_counts: response.member_counts,
            watchlist: response.watchlist,
            centers: response.centers,
            cycle_count_summary: response.cycle_count_summary
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
        <div className="col-md-10">
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
        <div className="col-md-2">
          <div className="form-group">
            <label>
              Actions
            </label>
            <br/>
            <button
              className="btn btn-primary btn-block"
              onClick={this.handleSyncClicked.bind(this)}
              disabled={this.state.isLoading}
            >
              <span className="fa fa-sync"/>
              Sync
            </button>
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

      o.loan_products.forEach(function(e) {
        loanProductRows.push(
          <tr key={"lp-" + e.id}>
            <td>
              <strong>
                {e.name}
              </strong>
            </td>
            <td className="text-center">
              {e.active_loans}
            </td>
            <td className="text-right">
              {numberWithCommas(e.principal)}
            </td>
            <td className="text-right">
              {numberWithCommas(e.principal_paid)}
            </td>
            <td className="text-right">
              {numberWithCommas(e.portfolio)}
            </td>
            <td className="text-right">
              {numberWithCommas(e.principal_past_due_amount)}
            </td>
            <td className="text-right">
              {numberWithCommas(e.par_amount)}
            </td>
            <td className="text-center">
              <small>
                {numberAsPercent(e.par_rate)}
              </small>
              <div className="progress progress-xs">
                <div className="progress-bar bg-danger" role="progressbar" style={{width: "" + numberAsPercent(e.par_rate)}}>
                </div>
              </div>
            </td>
            <td className="text-center">
              <small>
                {numberAsPercent(e.rr)}
              </small>
              <div className="progress progress-xs">
                <div className="progress-bar bg-success" role="progressbar" style={{width: "" + numberAsPercent(e.rr)}}>
                </div>
              </div>
            </td>
          </tr>
        );
      });

      return  (
        <div>
          <h5>
            Loans Stats as of {o.as_of}
          </h5>
          <div className="row">
            <div className="col">
              <h6>
                Overall PAR: {numberAsPercent(o.total_par_rate)}
              </h6>
              <div className="progress progress-xs">
                <div className="progress-bar bg-danger" role="progressbar" style={{width: "" + numberAsPercent(o.total_par_rate)}}>
                </div>
              </div>
            </div>
            <div className="col">
              <h6>
                Overall Repayment Rate: {numberAsPercent(o.total_rr)}
              </h6>
              <div className="progress progress-xs">
                <div className="progress-bar bg-success" role="progressbar" style={{width: "" + numberAsPercent(o.total_rr)}}>
                </div>
              </div>
            </div>
          </div>
          <br/>
          <table className="table table-bordered table-sm table-hover">
            <thead>
              <tr style={{backgroundColor: "#797979", color: "#fff"}}>
                <th>
                  Loan Product
                </th>
                <th className="text-center">
                  Active Loans
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
              <tr style={{backgroundColor: "#f0f0f0"}}>
                <th>
                  Total
                </th>
                <th className="text-center">
                  {o.total_active_loans}
                </th>
                <th className="text-right">
                  {numberWithCommas(o.total_principal)}
                </th>
                <th className="text-right">
                  {numberWithCommas(o.total_principal_paid)}
                </th>
                <th className="text-right">
                  {numberWithCommas(o.total_portfolio)}
                </th>
                <th className="text-right">
                  {numberWithCommas(o.total_principal_past_due_amount)}
                </th>
                <th className="text-right">
                  {numberWithCommas(o.total_par_amount)}
                </th>
                <th className="text-center">
                  {numberAsPercent(o.total_par_rate)}
                  <div className="progress progress-xs">
                    <div className="progress-bar bg-danger" role="progressbar" style={{width: "" + numberAsPercent(o.total_par_rate)}}>
                    </div>
                  </div>
                </th>
                <th className="text-center">
                  {numberAsPercent(o.total_rr)}
                  <div className="progress progress-xs">
                    <div className="progress-bar bg-success" role="progressbar" style={{width: "" + numberAsPercent(o.total_rr)}}>
                    </div>
                  </div>
                </th>
              </tr>
            </tfoot>
          </table>
        </div>
      );
    }
  }

  renderCycleCountSummary() {
    var o = this.state.data.cycle_count_summary;

    if(this.state.isLoading) {
      return  (
        <SkCubeLoading/>
      );
    } else if(!o) {
      return  (
        <p>
          No data found for cycle count summary.
        </p>
      );
    } else {
      var rows  = [];

      for(var i = 0; i < o.records.length; i++) {
        var cols = [];

        for(var j = 0; j < o.records[i].loan_products.length; j++) {
          cols.push(
            <td key={"row-" + i + "-" + o.records[i].loan_products[j].id} className="text-center">
              <a href="#" onClick={this.handleCycleCountClicked.bind(this, o.records[i].loan_products[j].id, o.records[i].cycle)}>
                {o.records[i].loan_products[j].count}
              </a>
            </td>
          );
        }

        rows.push(
          <tr key={"cycle-count-summary-" + i}>
            <td key={"cycle-val-" + i} className="text-center">
              {o.records[i].cycle}
            </td>
            {cols}
            <td key={"cycle-total-" + i} className="text-center">
              {o.records[i].total}
            </td>
          </tr>
        );
      }

      return (
        <div>
          <Modal
            isOpen={this.state.modalCycleCountSummaryIsOpen}
            style={customStyles}
            contentLabel="Example Modal"
          >
            <h2>
              Member List
            </h2>
            <hr/>
            <table className="table table-sm table-bordered">
              <thead>
                <tr>
                  <th width={"5%"}>
                  </th>
                  <th>
                    Name
                  </th>
                </tr>
              </thead>
              <tbody>
                {
                  this.state.currentMemberList.map((m, index) => (
                      <tr key={"member-" + index}>
                        <td className="text-center">
                          <a href={"/members/" + m.member.id + "/display"}>
                            <span className="fa fa-search"/>
                          </a>
                        </td>
                        <td>
                          {m.member.last_name}, {m.member.first_name}
                        </td>
                      </tr>
                    )
                  )
                }
              </tbody>
            </table>
            <hr/>
            <button 
              onClick={this.closeCycleCountSummaryModal.bind(this)}
              className="btn btn-danger btn-sm"
            >
              <span className="fa fa-times"/>
              Close
            </button>
          </Modal>

          <h5>
            Loan Cycle Count Summary
          </h5>

          <div className="table-responsive">
            <table className="table table-bordered table-sm">
              <thead>
                <tr style={{backgroundColor: "#797979", color: "#fff"}}>
                  {
                    o.headers.map((h, index) => (
                        <th key={"header-" + index} className="text-center" style={{whiteSpace: "nowrap"}}>
                          {h}
                        </th>
                      )
                    )
                  }
                </tr>
              </thead>
              <tbody>
                {rows}
              </tbody>
              <tfoot>
                <tr style={{backgroundColor: "#f0f0f0"}}>
                  {
                    o.totals.map((t, index) => (
                        <th key={"total-" + index} className="text-center">
                          {t}
                        </th>
                      )
                    )
                  }
                </tr>
              </tfoot>
            </table>
          </div>
        </div>
      );
    }
  }

  renderWatchlist() {
    var o = this.state.data.watchlist;

    if(this.state.isLoading) {
      return  (
        <SkCubeLoading/>
      );
    } else if(!o) {
      return  (
        <p>
          No data found for member counts.
        </p>
      );
    } else {
      var rows  = [];

      for(var i = 0; i < o.records.length; i++) {
        rows.push(
          <tr key={"watchlist-record-" + o.records[i].id}>
            <td className="text-center">
              {i + 1}
            </td>
            <td>
              <strong>
                <a href={"/loans/" + o.records[i].id}>
                  {o.records[i].member.last_name}, {o.records[i].member.first_name} {o.records[i].member.middle_name}
                </a>
              </strong>
            </td>
            <td>
              {o.records[i].center.name}
            </td>
            <td>
              {o.records[i].officer.last_name}, {o.records[i].officer.first_name}
            </td>
            <td>
              {o.records[i].loan_product.name}
            </td>
            <td className="text-right text-muted">
              {numberWithCommas(o.records[i].principal_balance)}
            </td>
            <td className="text-right text-muted">
              {numberWithCommas(o.records[i].interest_balance)}
            </td>
            <td className="text-right">
              <strong>
                {numberWithCommas(o.records[i].total_balance)}
              </strong>
            </td>
          </tr>
        );
      }

      return  (
        <div>
          <h5>
            Watchlist as of {o.as_of} ({o.records.length})
          </h5>

          <table className="table table-bordered table-sm table-hover">
            <thead>
              <tr style={{backgroundColor: "#797979", color: "#fff"}}>
                <th>
                </th>
                <th>
                  Member
                </th>
                <th>
                  Center
                </th>
                <th>
                  Officer
                </th>
                <th>
                  Loan Product
                </th>
                <th className="text-right">
                  Principal Past Due
                </th>
                <th className="text-right">
                  Interest Past Due
                </th>
                <th className="text-right">
                  Total Past Due
                </th>
              </tr>
            </thead>
            <tbody>
              {rows}
            </tbody>
          </table>
        </div>
      );
    }
  }

  renderMemberTypeCounts(memberTypeCounts) {
    return (
      <div className="row">
        {
          memberTypeCounts.map((o) => (
              <div className='col' key={"mem-type-" + o.member_type}>
                <label>{o.member_type}:&nbsp;</label>
                <span className="text-muted">
                  {o.count}
                </span>
              </div>
            )
          )
        }
      </div>
    );
  }

  renderCenters() {
    var o = this.state.data.centers;

    if(this.state.isLoading) {
      return  (
        <SkCubeLoading/>
      );
    } else if(!o) {
      return  (
        <p>
          No data found for centers.
        </p>
      );
    } else {
      var centerRecords = [];
      var centers       = this.state.data.centers.centers;

      for(var i = 0; i < centers.length; i++) {
        centerRecords.push(
          <tr key={"center-meeting-day-" + i}>
            <td>
              {centers[i].name}
            </td>
            <td>
              {centers[i].officer.last_name}, {centers[i].officer.first_name}
            </td>
            <td className="text-center">
              {centers[i].active_count} | {centers[i].pending_count}
            </td>
            <td>
              {centers[i].meeting_day_display}
            </td>
          </tr>
        );
      }

      return (
        <div>
          <h5>
            Center Meeting Days
          </h5>
          <table className="table table-bordered table-sm table-hover">
            <thead>
              <tr style={{backgroundColor: "#797979", color: "#fff"}}>
                <th>
                  Name
                </th>
                <th>
                  Officer
                </th>
                <th className="text-center">
                  A | P
                </th>
                <th>
                  Meeting Day
                </th>
              </tr>
            </thead>
            <tbody>
              {centerRecords}
            </tbody>
          </table>
        </div>
      );
    }
  }

  renderMemberCounts() {
    var o = this.state.data.member_counts;

    if(this.state.isLoading) {
      return  (
        <SkCubeLoading/>
      );
    } else if(!o) {
      return  (
        <p>
          No data found for member counts.
        </p>
      );
    } else {
      return  (
        <div>
          <h5>
            <a href={"/data_stores/member_counts/" + o.id} target='_blank'>
              Member Counts as of {o.meta.as_of}
            </a>
          </h5>
          {this.renderMemberTypeCounts(o.data.member_type_counts)}
          <table className="table table-bordered table-sm table-hover">
            <thead>
              <tr style={{backgroundColor: "#797979", color: "#fff"}}>
                <th>
                </th>
                <th className="text-center">
                  Male
                </th>
                <th className="text-center">
                  Female
                </th>
                <th className="text-center">
                  Others
                </th>
                <th className="text-center">
                  TOTAL
                </th>
              </tr>
            </thead>
            <tbody>
              <tr>
                <th>
                  Pure Savers
                </th>
                <td className="text-center">
                  {o.data.counts.pure_savers.male}
                </td>
                <td className="text-center">
                  {o.data.counts.pure_savers.female}
                </td>
                <td className="text-center">
                  {o.data.counts.pure_savers.others}
                </td>
                <td className="text-center">
                  {o.data.counts.pure_savers.total}
                </td>
              </tr>
              <tr>
                <th>
                  Active Loaners
                </th>
                <td className="text-center">
                  {o.data.counts.loaners.male}
                </td>
                <td className="text-center">
                  {o.data.counts.loaners.female}
                </td>
                <td className="text-center">
                  {o.data.counts.loaners.others}
                </td>
                <td className="text-center">
                  {o.data.counts.loaners.total}
                </td>
              </tr>
              <tr>
                <th>
                  Active Members
                </th>
                <td className="text-center">
                  {o.data.counts.active_members.male}
                </td>
                <td className="text-center">
                  {o.data.counts.active_members.female}
                </td>
                <td className="text-center">
                  {o.data.counts.active_members.others}
                </td>
                <td className="text-center">
                  {o.data.counts.active_members.total}
                </td>
              </tr>
              <tr>
                <th>
                  GRAND TOTAL
                </th>
                <th className="text-center">
                  {o.data.counts.active_members.male + o.data.counts.loaners.male + o.data.counts.pure_savers.male}
                </th>
                <th className="text-center">
                  {o.data.counts.active_members.female + o.data.counts.loaners.female + o.data.counts.pure_savers.female}
                </th>
                <th className="text-center">
                  {o.data.counts.active_members.others + o.data.counts.loaners.others + o.data.counts.pure_savers.others}
                </th>
                <th className="text-center">
                  {o.data.counts.active_members.total + o.data.counts.loaners.total + o.data.counts.pure_savers.total}
                </th>
              </tr>
            </tbody>
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
        {this.renderMemberCounts()}
        {this.renderWatchlist()}
        {this.renderCenters()}
        {this.renderCycleCountSummary()}
      </div>
    );
  }
}
