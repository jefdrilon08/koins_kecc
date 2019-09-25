import React from 'react';

export default class ResignationDisplay extends React.Component {
  constructor(props) {
    super(props);

    this.state = {
    };
  }

  render() {
    var data  = this.props.data;

    console.log(data);

    var rowCounts = [];
    var total     = 0;

    for(var i = 0; i < data.particulars.length; i++) {
      total += data.particulars[i].records.length;

      rowCounts.push(
        <tr key={this.props.index + "-particular-" + i}>
          <td>
            {data.particulars[i].code}: {data.particulars[i].name}
          </td>
          <td className="text-center">
            {data.particulars[i].records.length}
          </td>
          <td className="text-center">
            <button
              className="btn btn-sm btn-info"
            >
              Details
            </button>
          </td>
        </tr>
      );
    }

    return (
      <div>
        <h4>
          {data.name} ({total})
        </h4>
        <table className="table table-sm table-bordered">
          <thead>
            <tr>
              <th width="50%">
                Particular
              </th>
              <th className="text-center" width="25%">
                Count
              </th>
              <th className="text-center" width="25%">
                Actions
              </th>
            </tr>
          </thead>
          <tbody>
            {rowCounts}
          </tbody>
        </table>
      </div>
    );
  }
}
