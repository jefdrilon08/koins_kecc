import React, { useState, useEffect } from "react";
import ErrorList from '../ErrorList';
import Select from 'react-select';
import { months, getYears } from '../utils/consts';
import { generate } from '../services/PsrScheduleService';
import { numberAsPercent, numberWithCommas } from "../utils/helpers";

const Generate = (props) => {
  const [currentBranches, setCurrentBranches] = useState([]);
  const [currentYear, setCurrentYear] = useState(new Date().getFullYear());
  const [currentMonth, setCurrentMonth] = useState(new Date().getMonth() + 1);
  const [isLoading, setIsLoading] = useState(false);
  const [errors, setErrors] = useState([]);
  const [data, setData] = useState([]);
  


  const handleClick = () => {
    setIsLoading(true);
    setErrors([]);
    setData([]);

    const payload = {
      branch_ids: currentBranches.map((o) => { return o.value }),
      year: currentYear,
      month: currentMonth,
    }

    generate(payload, props.token).then((res) => {
      console.log(res.data);
      setData(res.data);
    }).catch((res) => {
      setErrors(res.response.data.errors);
    }).finally(() => {
      setIsLoading(false);
    })
  }
  
  return (
    <React.Fragment>
      <h1>
        Generate PSR Schedule
      </h1>
      <hr/>
      <label>
        SatO
      </label>
      <Select
        value={currentBranches}
        options={props.branch_options}
        isMulti
        isDisabled={isLoading}
        onChange={(selections) => {
          const _currentBranches = [];

          selections.forEach((o) => {
            _currentBranches.push(o);
          })

          setCurrentBranches(_currentBranches);
        }}
      />
      <div className="row mt-2">
        <div className="col">
          <div className="form-group">
            <label>
              Month
            </label>
            <select
              className="form-control"
              value={currentMonth}
              disabled={isLoading}
              onChange={(event) => {
                setCurrentMonth(event.target.value);
              }}
            >
              {months.map((month) => {
                return (
                  <option value={month.value} key={`month-${month.value}`}>
                    {month.label}
                  </option>
                )
              })}
            </select>
          </div>
        </div>
        <div className="col">
          <div className="form-group">
            <label>
              Year
            </label>
            <select
              className="form-control"
              value={currentYear}
              disabled={isLoading}
              onChange={(event) => {
                setCurrentYear(event.target.value);
              }}
            >
              {getYears().map((year) => {
                return (
                  <option value={year} key={`year-${year}`}>
                    {year}
                  </option>
                )
              })}
            </select>
          </div>
        </div>
      </div>
      <button
        className="btn btn-info w-100 mt-2"
        disabled={isLoading}
        onClick={() => {
          setIsLoading(true);
          handleClick();
        }}
      >
        Generate
      </button>
      <hr/>
      <ErrorList errors={errors}/>
      {(() => {
        if(data.length > 0) {
          return (	  
	     <React.Fragment>
              <table className="table table-bordered table-sm">
                <tbody>
                  <tr>
                    <th>
                      SatO
                    </th>
                    {data.map((obj) => {
                      return (
                        <th className="text-center" key={`branch-header-${obj.branch_id}`}>
                          {obj.branch}
                        </th>
                      )
                    })}
                  </tr>
		  <tr>
		   <th>
		     A. OUTREACH
		   </th>
		   <td></td>
		  </tr>
		  <tr>
                    <th>
                      a1. Total Number of Active Members
                    </th>
                    {data.map((obj) => {
                      return (
                        <th className="text-center" key={`active-total-${obj.branch_id}`}>
                          {obj.data.active_total}
                        </th>
                      )
                    })}
                  </tr>
                  <tr>
                    <th className="ps-4">
                      Female
                    </th>
                    {data.map((obj) => {
                      return (
                        <td className="text-center" key={`active-female-${obj.branch_id}`}>
                          {obj.data.active_female}
                        </td>
                      )
                    })}
                  </tr>
                  <tr>
                    <th className="ps-4">
                      Male
                    </th>
                    {data.map((obj) => {
                      return (
                        <td className="text-center" key={`active-male-${obj.branch_id}`}>
                          {obj.data.active_male}
                        </td>
                      )
                    })}
                  </tr>
                  <tr>
                    <th>
                      Pure Savers
                    </th>
                    {data.map((obj) => {
                      return (
                        <td className="text-center" key={`pure-savers-${obj.branch_id}`}>
                          {obj.data.pure_savers}
                        </td>
                      )
                    })}
                  </tr>
		  <tr>
                    <th className="ps-4">
                      Primary
                    </th>
                    {data.map((obj) => {
                      return (
                        <td className="text-center" key={`active-male-${obj.branch_id}`}>
                          {obj.data.pure_savers_regular}
                        </td>
                      )
                    })}
		  </tr>
		  <tr>
                    <th className="ps-4">
                      kaagapay
                    </th>
                    {data.map((obj) => {
                      return (
                        <td className="text-center" key={`active-male-${obj.branch_id}`}>
                          {obj.data.pure_savers_kaagapay}
                        </td>
                      )
                    })}
		  </tr>
		  <tr>
                    <th className="ps-4">
                      GK
                    </th>
                    {data.map((obj) => {
                      return (
                        <td className="text-center" key={`active-male-${obj.branch_id}`}>
                          {obj.data.pure_savers_gk}
                        </td>
                      )
                    })}
		  </tr>
		  <tr>
                    <th>
                      Active Borrowers
                    </th>
                    {data.map((obj) => {
                      return (
                        <td className="text-center" key={`active-borrowers-${obj.branch_id}`}>
                          {obj.data.active_borrowers}
                        </td>
                      )
                    })}
                  </tr>
		   <tr>
                    <th className="ps-4">
                      Primary
                    </th>
                    {data.map((obj) => {
                      return (
                        <td className="text-center" key={`active-male-${obj.branch_id}`}>
                          {obj.data.active_borrowers_regular}
                        </td>
                      )
                    })}
		  </tr>
		  <tr>
                    <th className="ps-4">
                      kaagapay
                    </th>
                    {data.map((obj) => {
                      return (
                        <td className="text-center" key={`active-male-${obj.branch_id}`}>
                          {obj.data.active_borrowers_kaagapay}
                        </td>
                      )
                    })}
		  </tr>
		  <tr>
                    <th className="ps-4">
                      GK
                    </th>
                    {data.map((obj) => {
                      return (
                        <td className="text-center" key={`active-male-${obj.branch_id}`}>
                          {obj.data.active_borrowers_gk}
                        </td>
                      )
                    })}
		  </tr>
		  <tr>
                    <th>
                      Admitted Members
                    </th>
                    {data.map((obj) => {
                      return (
                        <td className="text-center" key={`admitted-members-${obj.branch_id}`}>
                          {obj.data.admitted}
                        </td>
                      )
                    })}
		  </tr>
		  <tr>
                    <th>
                      Inactive Members
                    </th>
                    {data.map((obj) => {
                      return (
                        <td className="text-center" key={`admitted-members-${obj.branch_id}`}>
                          {obj.data.non_patronizing}
                        </td>
                      )
                    })}
		  </tr>

		  <tr>
                    <th>
                      Deliquent Members
		    </th>
		    <td></td>
		  </tr>
		{/*
                  <tr>
                    <th>
                      Resigned
                    </th>
                    {data.map((obj) => {
                      return (
                        <td className="text-center" key={`resigned-${obj.branch_id}`}>
                          {obj.data.resigned}
                        </td>
                      )
                    })}
                  </tr>
                  <tr>
                    <th>
                      Percentage of Savers
                    </th>
                    {data.map((obj) => {
                      return (
                        <td className="text-center" key={`percentage-of-savers-${obj.branch_id}`}>
                          {numberAsPercent(obj.data.pure_savers / obj.data.active_total)}
                        </td>
                      )
                    })}
                  </tr>
                  <tr>
                    <th>
                      Percentage of Borrowers
                    </th>
                    {data.map((obj) => {
                      return (
                        <td className="text-center" key={`percentage-of-borrowers-${obj.branch_id}`}>
                          {numberAsPercent(obj.data.active_borrowers / obj.data.active_total)}
                        </td>
                      )
                    })}
		  </tr>
		  */}
                  <tr>
                    <th>
                      a2. Total Number of Active Loans
                    </th>
                    {data.map((obj) => {
                      return (
                        <th className="text-center" key={`percentage-of-borrowers-${obj.branch_id}`}>
                          {obj.data.total_active_loans}
                        </th>
                      )
                    })}
                  </tr>
		  {data[0].data.loans
		    .sort((a, b) => a.loan_product.priority - b.loan_product.priority)
		    .map((o, i) => {
                    return (
                      <tr key={`loan-count-row-${i}`}>
                        <th className="ps-4">
                          {o.loan_product.name}
                        </th>
                        {data.map((obj) => {
                          return (
                            <td className="text-center" key={`loan-count-col-${obj.branch_id}`}>
                              {obj.data.loans[i].count}
                            </td>
                          )
                        })}
                      </tr>
                    )
		  })}
                  <tr>
                    <th>
                      a3. DROP OUT for the month
		    </th>
		    {data.map((obj) => {
                      return (
                        <th className="text-center" key={`percentage-of-borrowers-${obj.branch_id}`}>
                          {obj.data.resigned_members}
                        </th>
                      )
                    })}
                  </tr>
                  <tr>
                    <th className="ps-4">
                      Drop out rate
		    </th>
                        <td></td>
                  </tr>
                  <tr>
                    <th>
                      a4. Total New Clients (as of)
		    </th>
		    <td></td>
                  </tr>
                  <tr>
                    <th className="ps-4">
                      New clients for the month
		    </th>
 		    {data.map((obj) => {
                      return (
                        <th className="text-center" key={`percentage-of-borrowers-${obj.branch_id}`}>
                          {obj.data.new_members}
                        </th>
                      )
                   })}                       
                  </tr>

                  <tr>
                    <th>
                      B. LOAN PORTFOLIO
                    </th>
                    {data.map((obj) => {
                      return (
                        <th className="text-end" key={`outstanding-loans-${obj.branch_id}`}>
                          {numberWithCommas(obj.data.total_overall_principal_balance)}
                        </th>
                      )
                    })}
		  </tr>

                  <tr>
                    <th>
                      b1. Outstanding Loans
                    </th>
                    <td></td>
		  </tr>
                  <tr>
		  </tr>
                  {data[0].data.loans.map((o, i) => {
                    return (
                      <tr key={`loan-portfolio-row-${i}`}>
                        <th className="ps-4">
                          {o.loan_product.name}
                        </th>
                        {data.map((obj) => {
                          return (
                            <td className="text-end" key={`loan-portfolio-col-${obj.branch_id}`}>
                              {numberWithCommas(obj.data.loans[i].overall_principal_balance)}
                            </td>
                          )
                        })}
                      </tr>
                    )
		  })}
		  <tr>
                    <th>
                      Average Loan amount (portfolio) for the month
                    </th>
                    {data.map((obj) => {
                      return (
                        <th className="text-end" key={`average-loan-amount${obj.branch_id}`}>
                          {numberWithCommas(obj.data.average_loan_amount)}
                        </th>
                      )
                    })}
		  </tr>
		  <tr>
                    <th>
                      b2. PAST DUE AMOUNT:
                    </th>
		    <td></td>
		  </tr>
		  
		  <tr>
                    <th className="ps-4">
                      Past due (1-30 days)
                    </th>
                    {data.map((obj) => {
                      return (
                        <td className="text-end" key={`pastdue-month-${obj.branch_id}`}>
                          {numberWithCommas(obj.data.past_due_month)}
                        </td>
                      )
                    })}
		  </tr>
		  <tr>
                    <th className="ps-4">
                      Past due (31-365 days)
                    </th>
                    {data.map((obj) => {
                      return (
                        <td className="text-end" key={`pastdue-year-${obj.branch_id}`}>
                          {numberWithCommas(obj.data.past_due_year)}
                        </td>
                      )
                    })}
		  </tr>
		  <tr>
                    <th className="ps-4">
                      Past due (365 days above)
                    </th>
                    {data.map((obj) => {
                      return (
                        <td className="text-end" key={`pastdue-greateryear-${obj.branch_id}`}>
                          {numberWithCommas(obj.data.past_due_greater_year)}
                        </td>
                      )
                    })}
		  </tr>
		  <tr>
                    <th className="ps-4">
                      Total PAST DUE
                    </th>
                    {data.map((obj) => {
                      return (
                        <th className="text-end" key={`principal-balance-${obj.branch_id}`}>
                          {numberWithCommas(obj.data.total_principal_balance)}
                        </th>
                      )
                    })}
		  </tr>
		  <tr>
                    <th className="ps-4">
                      Past Due Rate
                    </th>
                    {data.map((obj) => {
                      return (
                        <td className="text-center" key={`pastdue-rate-${obj.branch_id}`}>
                          {numberAsPercent(obj.data.past_due_rate)}
                        </td>
                      )
                    })}
		  </tr>
		  <tr>
                    <th>
                      b3. PAR AMOUNT:
                    </th>
		    <td></td>
		  </tr>
		  
		  <tr>
                    <th className="ps-4">
                      Portfolio at Risk (1-30 days)
                    </th>
                    {data.map((obj) => {
                      return (
                        <td className="text-end" key={`par-month-${obj.branch_id}`}>
                          {numberWithCommas(obj.data.par_month)}
                        </td>
                      )
                    })}
		  </tr>
		  <tr>
                    <th className="ps-4">
                      Portfolio at Risk (31-365 days)
                    </th>
                    {data.map((obj) => {
                      return (
                        <td className="text-end" key={`par-year-${obj.branch_id}`}>
                          {numberWithCommas(obj.data.par_year)}
                        </td>
                      )
                    })}
		  </tr>
		  <tr>
                    <th className="ps-4">
                      Portfolio at Risk (365 days above)
                    </th>
                    {data.map((obj) => {
                      return (
                        <td className="text-end" key={`par-greateryear-${obj.branch_id}`}>
                          {numberWithCommas(obj.data.par_greater_year)}
                        </td>
                      )
                    })}
		  </tr>
		  <tr>
                    <th className="ps-4">
                      Total PAR AMOUNT
                    </th>
                    {data.map((obj) => {
                      return (
                        <th className="text-end" key={`par-balance-${obj.branch_id}`}>
                          {numberWithCommas(obj.data.total_par)}
                        </th>
                      )
                    })}
		  </tr>
		  <tr>
                    <th className="ps-4">
                      PAR Rate (1day)
                    </th>
                    {data.map((obj) => {
                      return (
                        <td className="text-center" key={`pastdue-rate-${obj.branch_id}`}>
                          {numberAsPercent(obj.data.par_rate_one_day)}
                        </td>
                      )
                    })}
		  </tr>
		  <tr>
                    <th>
                      b4. Allow. For Impairment losses
                    </th>
		    <td></td>
		  </tr>
		  
		  <tr>
                    <th className="ps-4">
                      Current (1%)
                    </th>
                    {data.map((obj) => {
                      return (
                        <td className="text-end" key={`afil-current-${obj.branch_id}`}>
                          {numberWithCommas(obj.data.afil_current)}
                        </td>
                      )
                    })}
		  </tr>
		  <tr>
                    <th className="ps-4">
                      1-365 days (35%)
                    </th>
                    {data.map((obj) => {
                      return (
                        <td className="text-end" key={`afil-year-${obj.branch_id}`}>
                          {numberWithCommas(obj.data.afil_year)}
                        </td>
                      )
                    })}
		  </tr>
		  <tr>
                    <th className="ps-4">
                      over 1 yr (100%)
                    </th>
                    {data.map((obj) => {
                      return (
                        <td className="text-end" key={`afil-greateryear-${obj.branch_id}`}>
                          {numberWithCommas(obj.data.afil_greater_year)}
                        </td>
                      )
                    })}
		  </tr>
		  <tr>
                    <th className="ps-4">
                      Total 
                    </th>
                    {data.map((obj) => {
                      return (
                        <th className="text-end" key={`afil-${obj.branch_id}`}>
                          {numberWithCommas(obj.data.afil)}
                        </th>
                      )
                    })}
		  </tr>
		  <tr>
                    <th>
                      b4. Allow. For Impairment losses
                    </th>
		    <td></td>
		  </tr>

                  <tr>
                    <th>
                      C. DISBURSEMENTS
		    </th>
		    <td></td>
		   </tr>
		  <tr>
                    <th>
                      c1. Total no. of LOAN DISBURSED (As of)
                    </th>
		    <td></td>
		  </tr>
		  <tr>
                    <th>
                      c2. No. of LOAN DISBURSED for the month
                    </th>
		    {data.map((obj) => {
                      return (
                        <th className="text-center" key={`loans-disbursed-for-the-month-${obj.branch_id}`}>
                          {obj.data.total_num_disbursed}
                        </th>
                      )
                    })}
		  </tr>

                  {data[0].data.loans.map((o, i) => {
                    return (
                      <tr key={`loans-disbursed-for-the-month-row-${i}`}>
                        <th className="ps-4">
                          {o.loan_product.name}
                        </th>
                        {data.map((obj) => {
                          return (
                            <td className="text-center" key={`loans-disbursed-for-the-month-col-${obj.branch_id}`}>
                              {obj.data.loans[i].num_disbursed}
                            </td>
                          )
                        })}
                      </tr>
                    )
		  })}
		  <tr>
                    <th>
                      c3. AMOUNT DISBURSED as of
                    </th>
		    <td></td>
		  </tr>

                  <tr>
                    <th>
                      c4. DISBURSEMENT for the month
                    </th>
                    {data.map((obj) => {
                      return (
                        <th className="text-end" key={`loans-total-amount-disbursed-${obj.branch_id}`}>
                          {numberWithCommas(obj.data.total_amount_disbursed)}
                        </th>
                      )
                    })}
                  </tr>
                  {data[0].data.loans.map((o, i) => {
                    return (
                      <tr key={`loans-amount-disbursed-row-${i}`}>
                        <th className="ps-4">
                          {o.loan_product.name}
                        </th>
                        {data.map((obj) => {
                          return (
                            <td className="text-end" key={`loans-amount-disbursed-col-${obj.branch_id}`}>
                              {numberWithCommas(obj.data.loans[i].amount_disbursed)}
                            </td>
                          )
                        })}
                      </tr>
                    )
		  })}
		  <tr>
                    <th>
                      Average Loan amount (disbursed) for the month
                    </th>
		    {data.map((obj) => {
                      return (
                        <th className="text-end" key={`loans-disbursed-for-the-month-${obj.branch_id}`}>
                          {numberWithCommas(obj.data.average_disbursed_amount)}
                        </th>
                      )
                    })}
		  </tr>
		  <tr>
                    <th>
                      d4. Amount collected (as of)
                    </th>
		    {data.map((obj) => {
                      return (
                        <th className="text-end" key={`loans-disbursed-for-the-month-${obj.branch_id}`}>
                          {numberWithCommas(obj.data.total_principal_paid)}
                        </th>
                      )
                    })}
		  </tr>
                  {data[0].data.loans.map((o, i) => {
                    return (
                      <tr key={`loans-amount-collected-row-${i}`}>
                        <th className="ps-4">
                          {o.loan_product.name}
                        </th>
                        {data.map((obj) => {
                          return (
                            <td className="text-end" key={`loans-amount-disbursed-col-${obj.branch_id}`}>
                              {numberWithCommas(obj.data.loans[i].total_principal_paid)}
                            </td>
                          )
                        })}
                      </tr>
                    )
		  })}
		  <tr>
                    <th>
                      Interest income (as of)
                    </th>
		    {data.map((obj) => {
                      return (
                        <th className="text-end" key={`loans-disbursed-for-the-month-${obj.branch_id}`}>
                          {numberWithCommas(obj.data.total_interest_paid)}
                        </th>
                      )
                    })}
		  </tr>
                  {data[0].data.loans.map((o, i) => {
                    return (
                      <tr key={`loans-amount-collected-row-${i}`}>
                        <th className="ps-4">
                          {o.loan_product.name}
                        </th>
                        {data.map((obj) => {
                          return (
                            <td className="text-end" key={`loans-amount-disbursed-col-${obj.branch_id}`}>
                              {numberWithCommas(obj.data.loans[i].total_interest_paid)}
                            </td>
                          )
                        })}
                      </tr>
                    )
		  })}

                  <tr>
                    <th>
                      Gross Income
                    </th>
                    {data.map((obj) => {
                      return (
                        <td className="text-end" key={`loans-gross-income-${obj.branch_id}`}>
                          {numberWithCommas(obj.data.gross_income)}
                        </td>
                      )
                    })}
                  </tr>
                  <tr>
                    <th>
                      Operating Expense
                    </th>
                    {data.map((obj) => {
                      return (
                        <td className="text-end" key={`loans-operating-expense-${obj.branch_id}`}>
                          {numberWithCommas(obj.data.operating_expense)}
                        </td>
                      )
                    })}
                  </tr>
                  <tr>
                    <th>
                      Net Income Before Admin Expense
                    </th>
                    {data.map((obj) => {
                      return (
                        <td className="text-end" key={`loans-net-income-before-admin-expense-${obj.branch_id}`}>
                          {numberWithCommas(obj.data.net_income_before_admin_expense)}
                        </td>
                      )
                    })}
                  </tr>
                </tbody>
              </table>
            </React.Fragment>
          )
        }
      })()}
      <hr/>
    </React.Fragment>
  )
}

export default Generate;
