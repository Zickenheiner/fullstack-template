import './index.css';
import { createRoot } from 'react-dom/client';
import Router from './app/Router';
import Provider from './app/Provider';

createRoot(document.getElementById('root')!).render(
  <Provider>
    <Router />
  </Provider>,
);
