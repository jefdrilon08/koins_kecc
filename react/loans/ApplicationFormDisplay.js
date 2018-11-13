import React from 'react';
import $ from 'jquery';
import moment from 'moment';

import SkCubeLoading from '../SkCubeLoading';
import AccountingEntryPreview from '../accounting/AccountingEntryPreview';
import {numberWithCommas} from '../utils/helpers';

export default class ApplicationFormDisplay extends React.Component {
  constructor(props) {
    super(props);

    this.state  = {
      isLoading: true,
      isSaving: false,
      data: false
    };
  }

  componentDidMount() {
  }

  render() {
    if(this.state.isLoading) {
      return  (
        <SkCubeLoading/>
      );
    } else {
      return  (
        <div>
          Application Form Content
        </div>
      );
    }
  }
}
