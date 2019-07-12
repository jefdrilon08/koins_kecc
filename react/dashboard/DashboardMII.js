import React from 'react';
import $ from 'jquery';
import Select from 'react-select';

import SkCubeLoading from '../SkCubeLoading';
import {numberAsPercent, numberWithCommas} from '../utils/helpers';

export default class DashboardMII extends React.Component {
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

        console.log(response);

        context.setState({
          branches: response.branches,
          currentBranch: currentBranch,
          data: {
            member_counts: response.member_counts,
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
          <table className="table table-bordered table-sm table-hover">
            <thead>
              <tr style={{backgroundColor: "#797979", color: "#fff"}}>
                <th>
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
                  Active Members
                </th>
                <td className="text-center">
                  {o.data.counts.active_members.inforce}
                </td>
                <td className="text-center">
                  {o.data.counts.active_members.lapsed}
                </td>
                <td className="text-center">
                  {o.data.counts.active_members.pending}
                </td>
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
                  {o.data.counts.active_members.inforce}
                </th>
                <th className="text-center">
                  {o.data.counts.active_members.lapsed}
                </th>
                <th className="text-center">
                  {o.data.counts.active_members.pending}
                </th>
                <th className="text-center">
                  {o.data.counts.active_members.male}
                </th>
                <th className="text-center">
                  {o.data.counts.active_members.female}
                </th>
                <th className="text-center">
                  {o.data.counts.active_members.others}
                </th>
                <th className="text-center">
                  {o.data.counts.active_members.total}
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
        {this.renderMemberCounts()}
      </div>
    );
  }
}
