import { isLoggedIn } from '@/core/local/session';
import { Navigate, useLocation } from 'react-router-dom';
import Layout from './Layout';

interface Props {
  redirect: string;
}

export default function Private({ redirect }: Props) {
  const location = useLocation();

  if (!isLoggedIn()) {
    return <Navigate to={redirect} state={{ from: location }} replace />;
  }

  return <Layout />;
}
