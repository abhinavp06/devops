import { Injectable } from '@nestjs/common';

@Injectable()
export class AppService {
  healthCheck(): string {
    return 'Service A is up and running!';
  }
}
