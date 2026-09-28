import { Injectable } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { CookieOptions, Response } from 'express';
import {
  ACCESS_TOKEN_COOKIE,
  LOGGED_IN_COOKIE,
  REFRESH_TOKEN_COOKIE,
  accessTokenCookieOptions,
  loggedInCookieOptions,
  refreshTokenCookieOptions,
} from '@core/configs/cookie.config';

@Injectable()
export class AuthCookieService {
  constructor(private readonly config: ConfigService) {}

  setAuthCookies(res: Response, accessToken: string, refreshToken: string) {
    res.cookie(
      ACCESS_TOKEN_COOKIE,
      accessToken,
      accessTokenCookieOptions(this.config),
    );
    res.cookie(
      REFRESH_TOKEN_COOKIE,
      refreshToken,
      refreshTokenCookieOptions(this.config),
    );
    res.cookie(LOGGED_IN_COOKIE, '1', loggedInCookieOptions(this.config));
  }

  clearAuthCookies(res: Response) {
    res.clearCookie(
      ACCESS_TOKEN_COOKIE,
      this.withoutMaxAge(accessTokenCookieOptions(this.config)),
    );
    res.clearCookie(
      REFRESH_TOKEN_COOKIE,
      this.withoutMaxAge(refreshTokenCookieOptions(this.config)),
    );
    res.clearCookie(
      LOGGED_IN_COOKIE,
      this.withoutMaxAge(loggedInCookieOptions(this.config)),
    );
  }

  private withoutMaxAge(options: CookieOptions): CookieOptions {
    const { maxAge: _maxAge, ...rest } = options;
    return rest;
  }
}
