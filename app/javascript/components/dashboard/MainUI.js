import React, { useState, useEffect } from 'react';
import $ from 'jquery';
import SkCubeLoading from '../SkCubeLoading';

// DASHBOARDS
import DashboardOAS from './DashboardOAS';
import DashboardMII from './DashboardMII';
import DashboardManagementMii from './DashboardManagementMii';

import ManagementOverview from './ManagementOverview';

export default function MainUI(props) {
  const [token]                                 = useState(props.token);
  const [isError, setIsError]                   = useState(false);
  const [isLoading, setIsLoading]               = useState(true);
  const [roles, setRoles]                       = useState(props.roles);
  const [username, setUsername]                 = useState(props.username);
  const [isMicroinsurance, setIsMicroinsurance] = useState(props.is_microinsurance);

  if(isMicroinsurance) {
    return (
      <>
        <DashboardManagementMii/>
        <DashboardMII/>
      </>
    )
  } else {
    return (
      <>
        <ul className="nav nav-tabs" role="tablist">
          <li className="nav-item">
            <a href="#overview" role="tab" data-bs-toggle="tab" aria-controls="overview" className="nav-link active show">
              Overview
            </a>
          </li>
          <li className="nav-item">
            <a href="#branch-stats" role="tab" data-bs-toggle="tab" aria-controls="branch-stats" className="nav-link">
              Branch Stats
            </a>
          </li>
        </ul>
        <div className="tab-content border-start border-bottom border-end">
          <div id="overview" className="overview p-3 tab-pane active show" role="tabpanel">
            <ManagementOverview
              token={props.token}
            />
          </div>
          <div id="branch-stats" className="branch-stats p-3 tab-pane" role="tabpanel">
            <DashboardOAS
              token={props.token}
            />
          </div>
        </div>
      </>
    )
  }
}
