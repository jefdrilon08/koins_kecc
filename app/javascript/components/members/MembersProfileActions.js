import React, { useState, useEffect } from "react";
import Button from 'react-bootstrap/Button';
import Modal from 'react-bootstrap/Modal';
import axios from 'axios';

export default function MembersProfileActions(props) {
  const [isLoading, setIsLoading]                 = useState(false);
  const [isModalUnlockOpen, setIsModalUnlockOpen] = useState(false);
  const [isModalSurveyOpen, setIsModalSurveyOpen] = useState(false);
  const [surveyId, setSurveyId]                   = useState(props.surveys.length > 0 ? props.surveys[0].id : "");
  const [errors, setErrors]                       = useState([]);
  const [modifiable, setModifiable]               = useState(props.member.modifiable);
  const [isModalBalikKasapiOpen, setModalBalikKasapiOpen] = useState(false);
  const [isModalDelete, setIsModalDelete]         = useState(false);
  const [isModalReinstateOpen, setModalReinstateOpen] = useState(false);
  const [dateReinstated, setDateReinstated]       = useState("");

  const handleReinstateClicked = () => {
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
      '/api/members/reinstate',
      payload,
      options
    ).then((res) => {
      console.log(res);
      alert("Successfully Reinstated");
      window.location.href="/members/" + props.memberId + "/display/";
    }).catch((error) => {
      console.log(error.response);
      setErrors(error.response.data.errors);
      setIsLoading(false);
    })
  }

  const handleCreateSurveyClicked = () => {
    setIsLoading(true);

    const payload = {
      id: props.memberId,
      survey_id: surveyId
    }

    const headers = {
      'X-KOINS-HQ-TOKEN': props.token
    }

    const options = {
      headers: headers
    }

    axios.post(
      '/api/members/create_survey',
      payload,
      options
    ).then((res) => {
      console.log(res);
      alert("Successfully created survey!");
      window.location.href="/members/" + props.memberId + "/survey_answers/" + res.data.id + "/form";
    }).catch((error) => {
      console.log(error.response);
      setErrors(error.response.data.errors);
      setIsLoading(false);
    })
  }

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
      window.location.href="/members/" + props.memberId + "/display/";
      setModifiable(!modifiable);
      setIsModalUnlockOpen(false);
      setIsLoading(false);
    }).catch((error) => {
      setErrors(error.response.data.errors);
      setIsLoading(false);
    })
  }

  const handleConfirmBalikKasapi = () => {
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
      '/api/members/balik_kasapi',
      payload,
      options
    ).then((res) => {
      alert("Successfully change member status!");
      window.location.href="/members/" + props.memberId + "/display/";
      setModifiable(!modifiable);
      setIsModalUnlockOpen(false);
      setIsLoading(false);
    }).catch((error) => {
      setErrors(error.response.data.errors);
      setIsLoading(false);
    })
  }

  const handleConfirmDelete = () => {
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
      '/api/members/delete',
      payload,
      options
    ).then((res) => { 
      alert("Successfully Delete");
      window.location.href="/members/";
      setIsModalDelete(false);
      setIsLoading(false);
      setIsLoading(false);
    }).catch((error) => {
      setErrors(error.response.data.errors);
      setIsLoading(false);
    })

  }
  return (
    <>
      <Modal
        show={isModalReinstateOpen}
      >
        <Modal.Header>
          <Modal.Title>
            Reinstate Member
          </Modal.Title>
        </Modal.Header>

        <Modal.Body>
          <div className="row">
            <div className="form-group">
              <label>
               Reinstatement Date
              </label>
              <input
                className="form-control"
                value={dateReinstated}
                disabled={isLoading}
                type="date"
                onChange={(event) => { setDateReinstated(event.target.value) } }
              />
            </div>
          </div>
        </Modal.Body>

        <Modal.Footer>
          <Button 
            variant="primary"
            onClick={() => {
              handleReinstateClicked();
            }}
            disabled={isLoading}
          >
            Confirm
          </Button>
          <Button 
            variant="secondary"
            onClick={() => { 
              setModalReinstateOpen(false) 
            }}
            disabled={isLoading}
          >
            Close
          </Button>
        </Modal.Footer>
      </Modal>

      <Modal
        show={isModalSurveyOpen}
      >
        <Modal.Header>
          <Modal.Title>
            New Member Survey
          </Modal.Title>
        </Modal.Header>

        <Modal.Body>
          <p>
            Select a Survey Type
          </p>
          <select
            value={surveyId}
            onChange={(event) => {
              setSurveyId(event.target.value);
            }}
            className="form-control"
          >
            {props.surveys.map((o) => {
                return (
                  <option value={o.id} key={`survey-${o.id}`}>
                    {o.name}
                  </option>
                )
              })
            }
          </select>
        </Modal.Body>

        <Modal.Footer>
          <Button 
            variant="primary"
            onClick={() => {
              handleCreateSurveyClicked();
            }}
            disabled={isLoading}
          >
            Confirm
          </Button>
          <Button 
            variant="secondary"
            onClick={() => { 
              setIsModalSurveyOpen(false) 
            }}
            disabled={isLoading}
          >
            Close
          </Button>
        </Modal.Footer>
      </Modal>
      
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
      
      <Modal
        show={isModalBalikKasapiOpen}
      >
        <Modal.Header>
          <Modal.Title>
            Unlock to Modify
          </Modal.Title>
        </Modal.Header>

        <Modal.Body>
          <p>
            Ibalik kasapi ang miyembro?
          </p>
        </Modal.Body>

        <Modal.Footer>
          <Button 
            variant="primary"
            onClick={() => { handleConfirmBalikKasapi() }}
            disabled={isLoading}
          >
            Confirm
          </Button>
          <Button 
            variant="secondary"
            onClick={() => { setModalBalikKasapiOpen(false) }}
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
              Member Survey
            </strong>
            <p>
              Gumawa ng bagong survey.
            </p>
            <button
              className="btn btn-primary"
              onClick={() => {
                setIsModalSurveyOpen(true)
              }}
            >
              New Survey
            </button>
          </div>
        </div>
      </div>

      <hr/>

      

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
      
      <hr/>
      <div className="row">
        <div className="col">
          <div className="note note-info">
            <strong>
              Modify
            </strong>
            <p>
              Palitan ang status ng miyember Resing/Balik kasapi.
            </p>
            {(() => {
              if(props.member.status == "active") {
                return (
                  <button
                    className="btn btn-secondary"
                    onClick={() => { window.location.href=`/members/${props.memberId}/form_resignation` }}
                  >
                    Resign Member
                  </button>
                )
              } else if(props.member.status == "resigned") {
                return (
                  <button
                    className="btn btn-warning"
                    onClick={() => { setModalBalikKasapiOpen(true) }}
                  >
                    <span className="bi bi-padlock"/>
                    Balik Kasapi
                  </button>
                )
              }
            })()}
          </div>
        </div>
      </div>

      <hr/>

      <div className="row">
        <div className="col">
          <div className="note note-info">
            <button
              className="btn btn-primary"
              onClick={() => { window.location.href=`/members/${props.memberId}/blip_form_pdf` }}
            >
              Generate BLIP Form
            </button>     
          </div>
        </div>
      </div>
      <hr/>

      <div className="row">
        <div className="col">
          <div className="note note-info">
            {(() => {
              if(props.member.data["reinstatement"] == null ) {
                return (
                  <button
                    className="btn btn-primary"
                    onClick={() => {
                      setModalReinstateOpen(true)
                    }}
                  >
                    Reinstate
                  </button>
                )
              } else if(props.member.data["reinstatement"]["is_reinstated"] == true || props.member.status == "pending"){
                return (
                  <button
                    className="btn btn-secondary"
                    onClick={() => { setModalReinstateOpen(false) }}
                  >
                    <span className="bi bi-padlock"/>
                    Already Reinstated OR Pending Status
                  </button>
                )
              }            
            })()}
          </div>
        </div>
      </div>
      <hr/>

      <div className="row">
        <div className="col">
          <div className="note note-info">
            {(() => {
              if(props.member.status == "pending" && props.member.identification_number == null) {
                return (
                  <button
                    className="btn btn-danger"
                    onClick={() => {
                setIsModalDelete(true)
              }}
                  >
                    Delete member
                  </button>
                )
              } else if(props.member.status == "active") {
                return (
                  <button
                    className="btn btn-secondary"
                    onClick={() => { setIsModalDelete(false) }}
                  >
                    <span className="bi bi-padlock"/>
                    Delete Member
                  </button>
                )
              }
            })()}
          </div>
        </div>
      </div>
      <Modal
        show={isModalDelete}
      >
        <Modal.Header>
          <Modal.Title>
            Delete Member
          </Modal.Title>
        </Modal.Header>

        <Modal.Body>
          <p>
            Are you sure you want to delete this member?
          </p>
        </Modal.Body>

        <Modal.Footer>
          <Button 
            variant="primary"
            onClick={() => { handleConfirmDelete() }}
            disabled={isLoading}
          >
            Confirm
          </Button>
          <Button 
            variant="secondary"
            onClick={() => { setIsModalDelete(false) }}
            disabled={isLoading}
          >
            Close
          </Button>
        </Modal.Footer>
      </Modal>
    </>
  )
}
