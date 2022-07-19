import React, { useState, useEffect } from "react";
import Button from 'react-bootstrap/Button';
import Modal from 'react-bootstrap/Modal';
import axios from 'axios';

export default function MembersProfileActions(props) {
  const [isLoading, setIsLoading]                 = useState(false);
  const [isModalUnlockOpen, setIsModalUnlockOpen] = useState(false);
  const [errors, setErrors]                       = useState([]);
  const [modifiable, setModifiable]               = useState(props.member.modifiable);

  const handleConfirmClicked = () => {
    setIsLoading(true);

    const payload = {
      id: props.memberId
    }

    const headers = {
      'X-KOINS-HQ-TOKEN': props.token
    }

    const options = {
      headers: headers
    }

    axios.post(
      '/api/members/unlock',
      payload,
      options
    ).then((res) => {
      setModifiable(!modifiable);
      setIsModalUnlockOpen(false);
      setIsLoading(false);
    }).catch((error) => {
      setErrors(error.response.data.errors);
      setIsLoading(false);
    })
  }

  return (
    <>
      <Modal
        show={isModalUnlockOpen}
      >
        <Modal.Header>
          <Modal.Title>
            Unlock to Modify
          </Modal.Title>
        </Modal.Header>

        <Modal.Body>
          <p>
            Are you sure you want to unlock this member?
          </p>
        </Modal.Body>

        <Modal.Footer>
          <Button 
            variant="primary"
            onClick={() => { handleConfirmClicked() }}
            disabled={isLoading}
          >
            Confirm
          </Button>
          <Button 
            variant="secondary"
            onClick={() => { setIsModalUnlockOpen(false) }}
            disabled={isLoading}
          >
            Close
          </Button>
        </Modal.Footer>
      </Modal>

      <div className="row">
        <div className="col">
          <div className="note note-info">
            <strong>
              Modify
            </strong>
            <p>
              Palitan ang impormasyon ukol sa myembrong ito.
            </p>
            {(() => {
              if(props.member.modifiable) {
                return (
                  <button
                    className="btn btn-secondary"
                    onClick={() => { window.location.href=`/members/form?id=${props.memberId}` }}
                  >
                    Edit Record
                  </button>
                )
              } else {
                return (
                  <button
                    className="btn btn-warning"
                    onClick={() => { setIsModalUnlockOpen(true) }}
                  >
                    <span className="bi bi-padlock"/>
                    Unlock to Modify
                  </button>
                )
              }
            })()}
          </div>
        </div>
      </div>
    </>
  )
}
