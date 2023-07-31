/*
import { getToken, getCurrentUser } from '../services/AuthService';

export const buildHeaders = (args) => {
  return {
    'Content-Type': 'application/json',
    'Authorization': `Bearer ${getToken()}`
  }
}

export const buildFileUploadHeaders = (args) => {
  return {
    'Content-Type': 'multipart/form-data',
    'Authorization': `Bearer ${getToken()}`
  }
}
*/

export const hasFormError = (errors, key) => {
  return errors[key] && errors[key].length > 0
}
