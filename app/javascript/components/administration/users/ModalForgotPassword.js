import React, {
  useState
} from 'react';

export default ModalForgotPassword = (props) => {
  const [email, setEmail]         = useState("");
  const [isOpen, setIsOpen]       = useState(false);
  const [isLoading, setIsLoading] = useState(false);

  return (
    <Modal
      show={isOpen}
    >
      <Modal.Header closeButton>
        <Modal.Title>
          Forgot Password
        </Modal.Title>
      </Modal.Header>
      <Modal.Body>
      </Modal.Body>
      <Modal.Footer>
        <button
          className="btn btn-primary"
          disabled={isLoading}
          onClick={() => {
            setIsLoading(true);
          }}
        >
          Update
        </button>
        <button
          className="btn btn-light"
          disabled={isLoading}
          onClick={() => {
            setIsLoading(false);
            setIsOpen(false);
          }}
        >
          Cancel
        </button>
      </Modal.Footer>
    </Modal>
  )
}
