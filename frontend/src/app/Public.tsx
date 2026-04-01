import {
  clearTokens,
  getAccessToken,
  getRefreshToken,
} from '@/core/local/storage';
import { Navigate, Outlet, useLocation } from 'react-router-dom';

interface Props {
  redirect: string;
}

export default function Public({ redirect }: Props) {
  const location = useLocation();
  const accessToken = getAccessToken();
  const refreshToken = getRefreshToken();

  if (!accessToken && !refreshToken) {
    clearTokens();
    return <Outlet />;
  }

  return <Navigate to={redirect} state={{ from: location }} replace />;
}
