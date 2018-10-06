import React from 'react';
import $ from 'jquery';

import ReactTable from 'react-table';
import DatePicker from 'react-datepicker';
import Select from 'react-select';
import 'react-table/react-table.css';

import SkCubeLoading from '../SkCubeLoading';
import moment from 'moment';

import 'react-datepicker/dist/react-datepicker.css';

export default class AccountingEntryFormDisplay extends React.Component {
  constructor(props) {
    super(props);

    this.state  = {
      isLoading: false,
      accountingEntryId: props.accountingEntryId,
      data: false
    };
  }

  componentDidMount() {
  }

  numberWithCommas(x) {
    x = (Math.round(x * 100) / 100).toFixed(2);

    if(x < 0) {
      x = x * -1; 
      x = "(" + x.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ",") + ")";
    } else {
      x = x.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ",");
    }   

    return x;

  }

  fetch() {
    var context     = this;

    if(this.props.accountingEntryId) {
      $.ajax({
        url: "/api/v1/accounting/fetch_accounting_entry",
        method: "GET",
        data: {
          start_date: start_date,
          end_date: end_date
        },
        dataType: 'json',
        success: function(response) {
          console.log(response);
          var data  = response.data;
          
          context.setState({
            isLoading: false,
            data: data
          });
        },
        error: function(response) {
          context.setState({
            isLoading: false,
            data: false
          });
        }
      });
    } else {
      context.setState({
        isLoading: false
      });
    }
  }

  handleSaveBtnClicked() {
    var context = this;
    
    context.setState({
      isLoading: true
    });
  }

  render() {
    var context = this;
    var state   = context.state;

    if(state.isLoading) {
      return  (
        <SkCubeLoading/>
      );
    } else {
      return (
        <div>
          <div className="row">
            <div className="col">
              <h6>
                Accounting Entry Form
              </h6>
            </div>
          </div>
        </div>
      );
    }
  }
}
