import React from 'react';
import $ from 'jquery';
import moment from 'moment';
import Select from 'react-select';
import Toggle from 'react-toggle';
import "react-toggle/style.css";

import SkCubeLoading from '../../SkCubeLoading';
import ErrorDisplay from '../../ErrorDisplay';
import {numberWithCommas} from '../../utils/helpers';


export default class ShowDisplay extends React.Component {
  constructor(props) {
    super(props);

    this.state  = {
      isLoading: true,
      data: false,
      errors: false,
      accountHeaders: [],
      officers: [],
      centers: [],
      currentOfficerId: "",
      currentCenterId: ""
    };
  }



  renderAccountHeaders() {
    var headers = [];

    // Member name
    headers.push(
      <th key="member-header">
        Member
      </th>
    );

    // Officer
    headers.push(
      <th key="officer-header">
        Officer
      </th>
    );

    // Center
    headers.push(
      <th key="center-header">
        Center
      </th>
    );


    return headers;
  }


  renderDisplay() {
    return  (
      <div>
        <table className="table table-sm table-bordered table-hover" style={{fontSize: "0.9em"}}>
          <thead>
            <tr>
              {this.renderAccountHeaders()}
            </tr>
         </thead>
        </table>
      </div>
    );
  }


  render() {
    return  (
      <div>
        {this.renderDisplay()}
      </div>
    );
    
  }
}
