import React from 'react';
import ReactTable from 'react-table';

import 'react-table/react-table.css';

export default class BillingUITable extends React.Component {
  constructor(props) {
    super(props);
  }

  render() {
    return (
      <ReactTable
        data={this.props.data.data.records}
        columns={[
          {
            Header: "Member",
            accessor: "member"
          }
        ]}
      />
    );
  }
}
