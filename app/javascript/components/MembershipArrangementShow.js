import React, { useState } from 'react';
import Toggle from 'react-toggle';

function MembershipArrangementShow(props) {
  const [id]            = useState(props.id);
  const [data, setData] = useState(props.data);

  function handleUseCoMakerOneChanged(event) {
    data.use_co_maker_one = event.target.checked;

    const payload = {
      id: id,
      data: data,
      authenticity_token: props.authenticityToken
    }

    $.ajax({
      url: "/api/v1/administration/membership_arrangements/update_data",
      method: 'POST',
      data: payload,
      success: function(response) {
        console.log("Successfully updated data");

        setData(data);
      },
      error: function(response) {
        console.log(response);
        alert("Error in updating data");
      }
    })
  }

  function handleUseCoMakerTwoChanged(event) {
    data.use_co_maker_two = event.target.checked;

    const payload = {
      id: id,
      data: data,
      authenticity_token: props.authenticityToken
    }

    $.ajax({
      url: "/api/v1/administration/membership_arrangements/update_data",
      method: 'POST',
      data: payload,
      success: function(response) {
        console.log("Successfully updated data");

        setData(data);
      },
      error: function(response) {
        console.log(response);
        alert("Error in updating data");
      }
    })
  }

  function handleUseCoMakerThreeChanged(event) {
    data.use_co_maker_three = event.target.checked;

    const payload = {
      id: id,
      data: data,
      authenticity_token: props.authenticityToken
    }

    $.ajax({
      url: "/api/v1/administration/membership_arrangements/update_data",
      method: 'POST',
      data: payload,
      success: function(response) {
        console.log("Successfully updated data");

        setData(data);
      },
      error: function(response) {
        console.log(response);
        alert("Error in updating data");
      }
    })
  }

  return (
    <div className="">
      <h4>
        Co-maker Settings for Loan Application
      </h4>
      <div className="row">
        <div className="col">
          <table className="table table-sm table-bordered">
            <thead>
              <tr>
                <th>
                  Co Maker One
                </th>
                <th>
                  Co Maker Two
                </th>
                <th>
                  Co Maker Three
                </th>
              </tr>
            </thead>
            <tbody>
              <tr>
                <td>
                  <Toggle
                    defaultChecked={data.use_co_maker_one === 'true'}
                    onChange={handleUseCoMakerOneChanged}
                    className="btn"
                  />
                </td>
                <td>
                  <Toggle
                    defaultChecked={data.use_co_maker_two === 'true'}
                    onChange={handleUseCoMakerTwoChanged}
                    className="btn"
                  />
                </td>
                <td>
                  <Toggle
                    defaultChecked={data.use_co_maker_three === 'true'}
                    onChange={handleUseCoMakerThreeChanged}
                    className="btn"
                  />
                </td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>
    </div>
  )
}

export default MembershipArrangementShow;
