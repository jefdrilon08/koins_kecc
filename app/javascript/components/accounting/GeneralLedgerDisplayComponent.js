import React from 'react';
import $ from 'jquery';

import ReactTable from 'react-table';
import DatePicker from 'react-datepicker';
import Select from 'react-select';
import 'react-table/react-table.css';

import SkCubeLoading from '../SkCubeLoading';
import GeneralLedgerEntry from './GeneralLedgerEntry';
import ErrorDisplay from '../ErrorDisplay';
import AccountingCodeMultiSelect from './AccountingCodeMultiSelect';

export default class GeneralLedgerDisplayComponent extends React.Component {
  constructor(props) {
    super(props);

    this.state = {
      isLoading: true,
      accountingCodeIds: [],
      data: false,
      id: props.id,
      xKoinsAppAuthSecret: props.xKoinsAppAuthSecret,
      userId: props.userId
    }
  }

  componentDidMount() {
    var context = this;

    $.ajax({
      url: "/api/v1/general_ledgers/fetch",
      method: 'GET',
      headers: {
        'X-KOINS-APP-AUTH-SECRET': context.state.xKoinsAppAuthSecret,
        'Access-Control-Allow-Methods': '*',
        'Access-Control-Allow-Headers': '*',
        'Access-Control-Allow-Origin': '*',
        'Access-Control-Allow-Credentials': 'true'
      },
      data: {
        id: context.state.id,
        user_id: context.state.userId
      },
      success: function(response) {
        context.setState({
          data: response.data,
          isLoading: false
        });
      },
      error: function(response) {
        console.log(response);
        alert("Something went wrong!");
      }
    });
  }

  handleAccountingCodeSelectChanged(o) {
    var accountingCodeIds = [];

    for(var i = 0; i < o.length; i++) {
      accountingCodeIds.push(o[i].value);
    }

    this.setState({
      accountingCodeIds: accountingCodeIds
    });
  }

  renderTable() {
    var context = this;
    var state   = context.state;


    if(!state.isLoading && state.data != false) {
      var generalLedgerEntries  = state.data.entries;

      if(state.accountingCodeIds.length > 0) {
        generalLedgerEntries  = generalLedgerEntries.filter(function(o) {
                                  return state.accountingCodeIds.includes(o.accounting_code_id);
                                });   
      }

      var generalLedgerComponents = [];

      generalLedgerEntries.forEach(function(o) {
        generalLedgerComponents.push(
          <GeneralLedgerEntry
            data={o}
            key={"glc-" + o.accounting_code_id}
          />
        );
      });

      return  (
        <div>
          {generalLedgerComponents}
        </div>
      );
    }
  }

  render() {
    var context = this;
    var state   = context.state;

    if(state.isLoading) {
      return (
        <SkCubeLoading/>
      );
    } else {
      var accountingCodeOptions = state.data.entries.map(function(o) {
                                    return {
                                      value: o.accounting_code_id,
                                      label: o.accounting_code_name
                                    }
                                  });
      return (
        <div>
          <Select
            options={accountingCodeOptions}
            onChange={this.handleAccountingCodeSelectChanged.bind(this)}
            isMulti
          />
          <hr/>
          {context.renderTable()}
        </div>
      );
    }
  }
}
