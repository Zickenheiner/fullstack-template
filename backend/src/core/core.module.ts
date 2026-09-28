import { Global, Module } from '@nestjs/common';
import { AuthCookieService } from '@core/services/auth-cookie.service';

@Global()
@Module({
  providers: [AuthCookieService],
  exports: [AuthCookieService],
})
export class CoreModule {}
