import React from 'react';
import $ from 'jquery';
import SkCubeLoading from '../SkCubeLoading';

// DASHBOARDS
import DashboardOAS from './DashboardOAS';
import DashboardManagement from './DashboardManagement';
import DashboardMII from './DashboardMII';
import DashboardManagementMii from './DashboardManagementMii';

export default class MainUI extends React.Component {
  constructor(props) {
    super(props);

    this.state  = {
      isError: false,
      isLoading: true,
      roles: props.roles,
      username: props.username,
      is_microinsurance: props.is_microinsurance
    };
  }

  componentDidMount() {
    var context = this;

    this.setState({
      isLoading: false
    });
  }

  renderDashboards() {
    var dashboards  = [];

    console.log("Parameters: ");
    console.log(this.state.is_microinsurance);

    if (this.state.is_microinsurance){
      dashboards.push(
        <DashboardManagementMii
          key={"dashboard-Management-Mii"}
        />
      );

      dashboards.push(
        <DashboardMII
          key={"dashboard-MII"}
        />
      );
    } else {
      dashboards.push(
        <DashboardManagement
          key={"dashboard-Management"}
        />
      );

      dashboards.push(
        <DashboardOAS
          key={"dashboard-OAS"}
        />
      );
    }

    return dashboards;
  }

  render() {
    var context = this;
    var state   = context.state;

    if(state.isLoading) {
      return  (
        <div>
          <SkCubeLoading/>
          <center>
            <h5>
              Initializing Dashboard
            </h5>
          </center>
        </div>
      );
    } else if(state.isError) {
      return  (
        <div>
          Dashboard ERROR
        </div>
      );
    } else {
      return  (
        <div>
          {this.renderDashboards()}
        </div>
      );
    }
  }
}
