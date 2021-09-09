import React, { useState } from 'react';
import Toggle from 'react-toggle';

function MembershipArrangementShow(props) {
  const [id]            = useState(props.id);
  const [data, setData] = useState(props.data);

  function handleUseCoMakerOneChanged(event) {
    data.use_co_maker_one = event.target.checked;

    console.log(data);

    setData(data);
  }

  return (
    <div className="">
      <h4>
        Co-maker Usage
      </h4>
      <div className="row">
        <div className="col-md-4 col-xs-12">
          <Toggle
            checked={data.use_co_maker_one}
            onChange={handleUseCoMakerOneChanged}
            className="btn"
          />
        </div>
      </div>
    </div>
  )
}

export default MembershipArrangementShow;
