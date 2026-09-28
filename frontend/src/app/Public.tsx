import { isLoggedIn } from '@/core/local/session';
import { Navigate, Outlet, useLocation } from 'react-router-dom';

interface Props {
  redirect: string;
}

export default function Public({ redirect }: Props) {
  const location = useLocation();

  if (!isLoggedIn()) {
    return <Outlet />;
  }

  return <Navigate to={redirect} state={{ from: location }} replace />;
}
