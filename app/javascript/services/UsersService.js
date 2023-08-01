import axios from 'axios';
import { 
  BASE_URL
} from 'env';

export const forgotPassword = (args) => {
  return axios.post(
    `${BASE_URL}/api/forgot_password`,
    args
  )
}
