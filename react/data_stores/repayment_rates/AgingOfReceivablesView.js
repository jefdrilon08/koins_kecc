import React from 'react';
import {numberWithCommas} from '../../utils/helpers';

export default class AgingOfReceivablesView extends React.Component {
  constructor(props) {
    super(props);

    this.state  = {
    }
  }

  render() {
    var data  = this.props.data;

    console.log("AoR Data:");
    console.log(data);

    return  (
      <div>
        Aging of Receivables
      </div>
    );
  }
}
