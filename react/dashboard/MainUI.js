import React from 'react';
import $ from 'jquery';

import ReactTable from 'react-table';
import 'react-table/react-table.css';

import SkCubeLoading from '../SkCubeLoading';

import {numberWithCommas, numberAsPercent} from '../utils/helpers';
import moment from 'moment';

export default class MainUI extends React.Component {
  constructor(props) {
    super(props);

    this.state  = {
      isLoading: true,
      data: false
    };
  }

  componentDidMount() {
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
    } else {
      return  (
        <div>
          [DASHBOARD] 
        </div>
      );
    }
  }
}
