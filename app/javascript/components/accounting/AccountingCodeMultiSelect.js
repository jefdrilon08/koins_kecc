import React from 'react';
import $ from 'jquery';
import Select from 'react-select';

export default class AccountingCodeMultiSelect extends React.Component {
  constructor(props) {
    super(props);

    this.state  = {
      accountingCodes: []
    }
  }

  componentDidMount() {
    var context = this;

    $.ajax({
      url: "/api/v1/accounting_codes",
      method: 'GET',
      success: function(response) {
        context.setState({
          accountingCodes: response.accounting_codes
        });
      },
      error: function(response) {
        console.log("Error in AccountingCodeMultiSelect:");
        console.log(response);
      }
    });
  }

  render() {
    var accountingCodeOptions = [];

    for(var i = 0; i < this.state.accountingCodes.length; i++) {
      accountingCodeOptions.push({
        value: this.state.accountingCodes[i].id,
        label: this.state.accountingCodes[i].name
      });
    }

    return  (
      <div>
        <Select
          options={accountingCodeOptions}
          onChange={this.props.handleAccountingCodeSelectChanged.bind(this)}
          isMulti
        />
      </div>
    );
  }
}
