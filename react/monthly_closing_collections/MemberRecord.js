import React from 'react';

export default class MemberRecord extends React.Component {
  constructor(props) {
    super(props);

    this.state  = {
      data: props.data
    }
  }

  renderMemberName() {
    var member  = this.state.data.member;

    return member.last_name + ", " + member.first_name;
  }

  renderRecords() {
    var records = [];
  }

  render() {
    return  (
      <div>
        <div className="row">
          <div className="col">
            <h4>
              {this.renderMemberName()}
            </h4>
          </div>
          <div className="col">
            <div className="text-right">
              {this.state.data.member_account.id}
            </div>
          </div>
        </div>

        <table className="table table-sm table-bordered">
          <thead>
            <tr>
              <th>
                Date
              </th>
              <th className="text-right">
                Beginning Balance
              </th>
              <th className="text-right">
                Amount
              </th>
              <th className="text-center">
                Type
              </th>
              <th className="text-right">
                Ending Balance
              </th>
            </tr>
          </thead>
          <tbody>
            {this.renderRecords()}
          </tbody>
        </table>
      </div>
    );
  }
}
