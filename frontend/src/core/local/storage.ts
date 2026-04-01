import secureLocalStorage from 'react-secure-storage';

const getAccessToken = () => {
  return secureLocalStorage.getItem('accessToken');
};

const getRefreshToken = () => {
  return secureLocalStorage.getItem('refreshToken');
};

const setAccessToken = (token: string) => {
  secureLocalStorage.setItem('accessToken', token);
};

const setRefreshToken = (token: string) => {
  secureLocalStorage.setItem('refreshToken', token);
};

const removeAccessToken = () => {
  secureLocalStorage.removeItem('accessToken');
};

const removeRefreshToken = () => {
  secureLocalStorage.removeItem('refreshToken');
};

const clearTokens = () => {
  removeAccessToken();
  removeRefreshToken();
};

export {
  getAccessToken,
  getRefreshToken,
  setAccessToken,
  setRefreshToken,
  removeAccessToken,
  removeRefreshToken,
  clearTokens,
};
