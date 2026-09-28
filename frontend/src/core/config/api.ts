import endpoints from '../constants/endpoints';
import routes from '../constants/routes';
import { ApiError } from '../errors/api.error';
import { clearSession } from '../local/session';
import type { QueryParams } from '../types/query.type';

interface Config {
  url: string;
  method: 'GET' | 'POST' | 'PATCH' | 'DELETE';
  headers?: HeadersInit;
  query?: QueryParams;
  data?: unknown;
}

const buildUrl = (url: string, query?: QueryParams) => {
  const fullUrl = `${import.meta.env.VITE_API_URL}${url}`;
  if (!query) return fullUrl;

  const searchParams = new URLSearchParams();
  Object.entries(query).forEach(([key, value]) => {
    searchParams.append(key, String(value));
  });
  return `${fullUrl}?${searchParams.toString()}`;
};

const buildHeaders = (extra?: HeadersInit): HeadersInit => ({
  'Content-Type': 'application/json',
  ...extra,
});

let refreshPromise: Promise<boolean> | null = null;

const refresh = async (): Promise<boolean> => {
  try {
    const response = await fetch(buildUrl(endpoints.auth.refresh), {
      method: 'POST',
      credentials: 'include',
    });
    return response.ok;
  } catch {
    return false;
  }
};

const tryRefresh = (): Promise<boolean> => {
  if (!refreshPromise) {
    refreshPromise = refresh().finally(() => {
      refreshPromise = null;
    });
  }
  return refreshPromise;
};

const request = async <T = unknown>(config: Config): Promise<T> => {
  const url = buildUrl(config.url, config.query);
  const init: RequestInit = {
    method: config.method,
    headers: buildHeaders(config.headers),
    body: config.data !== undefined ? JSON.stringify(config.data) : undefined,
    credentials: 'include',
  };

  let response = await fetch(url, init);

  if (response.status === 401) {
    const refreshed = await tryRefresh();

    if (!refreshed) {
      clearSession();
      window.location.href = routes.login;
      throw new ApiError('Session expirée', 401);
    }

    response = await fetch(url, init);
  }

  if (!response.ok) {
    const json = await response.json().catch(() => null);
    throw new ApiError(json?.message ?? 'Erreur inconnue', response.status);
  }

  return response.json() as Promise<T>;
};

export default request;
