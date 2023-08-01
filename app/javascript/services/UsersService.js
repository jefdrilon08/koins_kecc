import axios from 'axios';
import { 
  BASE_URL
} from 'env';
import {buildHeaders} from '../helpers/AppHelper';

export const fetchUsers = (args) => {
  return axios.get(
    `${BASE_URL}/api/v3/users`,
    {
      params: args,
      headers: buildHeaders()
    }
  )
}

export const forgotPassword = (args) => {
  return axios.post(
    `${BASE_URL}/api/forgot_password`,
    args
  )
}
