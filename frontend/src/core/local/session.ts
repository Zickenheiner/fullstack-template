const LOGGED_IN_COOKIE = 'logged_in';

const isLoggedIn = () => {
  return document.cookie
    .split(';')
    .some((cookie) => cookie.trim().startsWith(`${LOGGED_IN_COOKIE}=`));
};

const clearSession = () => {
  document.cookie = `${LOGGED_IN_COOKIE}=; Max-Age=0; path=/; SameSite=Strict`;
};

export { isLoggedIn, clearSession };
