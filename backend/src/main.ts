import { NestFactory } from '@nestjs/core';
import { AppModule } from './app.module';
import * as mongoSanitize from 'express-mongo-sanitize';
import { ValidationPipe } from '@nestjs/common';
import { DocumentBuilder, SwaggerModule } from '@nestjs/swagger';
import { apiReference } from '@scalar/nestjs-api-reference';
import * as cookieParser from 'cookie-parser';

async function bootstrap() {
  const app = await NestFactory.create(AppModule);
  app.use((req: { query: any }, _res: any, next: () => void) => {
    Object.defineProperty(req, 'query', {
      ...Object.getOwnPropertyDescriptor(req, 'query'),
      value: req.query,
      writable: true,
    });
    next();
  });
  app.use(mongoSanitize());
  app.useGlobalPipes(
    new ValidationPipe({
      whitelist: true,
      transform: true,
    }),
  );
  const config = new DocumentBuilder()
    .setTitle('Mon API')
    .setDescription('Documentation API')
    .setVersion('1.0')
    .addBearerAuth(
      { type: 'http', scheme: 'bearer', bearerFormat: 'JWT' },
      'AccessToken',
    )
    .build();

  app.use(cookieParser(process.env.COOKIE_SECRET));
  const document = SwaggerModule.createDocument(app, config);
  app.use('/api', apiReference({ spec: { content: document } }));
  app.enableCors({
    origin: process.env.CORS_ORIGIN,
    methods: 'GET,PATCH,POST,DELETE',
    credentials: true,
  });
  await app.listen(process.env.PORT!);
}
bootstrap().catch((error) => {
  console.error('Error during application bootstrap:', error);
});
