import React from 'react';
import $ from 'jquery';

import SkCubeLoading from '../SkCubeLoading';
import {numberAsPercent, numberWithCommas} from '../utils/helpers';

import ManagementOverview from './ManagementOverview';

export default class DashboardManagement extends React.Component {
  constructor(props) {
    super(props);

    this.state  = {
    }
  }

  componentDidMount() {
    var context = this;
  }

  render() {
    return (
      <div>
        <ManagementOverview
        />
      </div>
    );
  }
}
