import { NestFactory } from '@nestjs/core';
import { ValidationPipe } from '@nestjs/common';
import { DocumentBuilder, SwaggerModule } from '@nestjs/swagger';
import { AppModule } from './app.module';

async function bootstrap() {
  const app = await NestFactory.create(AppModule);

  // Enable validation
  app.useGlobalPipes(
    new ValidationPipe({
      whitelist: true,
      forbidNonWhitelisted: true,
      transform: true,
    }),
  );

  // Enable CORS
  app.enableCors();

  // Swagger configuration
  const config = new DocumentBuilder()
    .setTitle('Coal Mining Management API')
    .setDescription('API for managing coal mining operations')
    .setVersion('1.0')
    .addTag('clients', 'Client management endpoints')
    .addTag('mining-sites', 'Mining site management endpoints')
    .addTag('expenses', 'Expense tracking endpoints')
    .addTag('income', 'Income tracking endpoints')
    .addTag('partners', 'Partner management endpoints')
    .addTag('workers', 'Worker/Labor management endpoints')
    .addTag('equipment', 'Equipment management endpoints')
    .addTag('production', 'Production tracking endpoints')
    .addTag('truck-deliveries', 'Truck delivery tracking endpoints')
    .addTag('users', 'User management endpoints')
    .build();

  const document = SwaggerModule.createDocument(app, config);
  SwaggerModule.setup('api', app, document);

  const port = process.env.PORT ?? 3000;
  await app.listen(port, '0.0.0.0');
  
  console.log(`🚀 Application is running on: http://localhost:${port}`);
  console.log(`📱 For physical devices use: http://192.168.0.165:${port}`);
  console.log(`📚 Swagger documentation available at: http://localhost:${port}/api`);
}
bootstrap();
