import axios from 'axios';

export const generate = (payload, token) => {
  const csrfToken = document.querySelector('meta[name="csrf-token"]').getAttribute('content');

  return axios.post(
    '/api/allowance_losses/generate',
    payload,
    {
      headers: {
        'X-CSRF-Token': csrfToken,
        'X-KOINS-ACCESS-TOKEN': token,
        'Content-Type': 'application/json'
      }
    }
  );
};
