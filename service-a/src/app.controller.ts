import { Controller, Get, Logger } from '@nestjs/common';

import { AppService } from './app.service';

@Controller()
export class AppController {
  constructor(private readonly appService: AppService) {}

  @Get()
  healthCheck(): string {
    return this.appService.healthCheck();
  }

  @Get('/hello')
  helloCron(): string {
    Logger.log('Hi there! This is service A');
    return 'Hi there! This is service A';
  }
}
