import { ConfigService } from '@nestjs/config';
import { CookieOptions } from 'express';
import * as ms from 'ms';

export const ACCESS_TOKEN_COOKIE = 'access_token';
export const REFRESH_TOKEN_COOKIE = 'refresh_token';
export const LOGGED_IN_COOKIE = 'logged_in';

const baseCookieOptions = (config: ConfigService): CookieOptions => ({
  secure: config.get<string>('APP_PROTOCOL') === 'https',
  sameSite: 'strict',
});

export const accessTokenCookieOptions = (
  config: ConfigService,
): CookieOptions => ({
  ...baseCookieOptions(config),
  httpOnly: true,
  path: '/',
  maxAge: ms(config.getOrThrow<ms.StringValue>('ACCESS_TOKEN_EXPIRATION_TIME')),
});

export const refreshTokenCookieOptions = (
  config: ConfigService,
): CookieOptions => ({
  ...baseCookieOptions(config),
  httpOnly: true,
  path: config.getOrThrow<string>('REFRESH_COOKIE_PATH'),
  maxAge: ms(
    config.getOrThrow<ms.StringValue>('REFRESH_TOKEN_EXPIRATION_TIME'),
  ),
});

export const loggedInCookieOptions = (
  config: ConfigService,
): CookieOptions => ({
  ...baseCookieOptions(config),
  httpOnly: false,
  path: '/',
  maxAge: ms(
    config.getOrThrow<ms.StringValue>('REFRESH_TOKEN_EXPIRATION_TIME'),
  ),
});
