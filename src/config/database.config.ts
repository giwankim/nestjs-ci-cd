import { registerAs } from '@nestjs/config';
import * as process from 'process';

export default registerAs('database', () => {
  return {
    host: process.env.POSTGRES_HOST,
    port: parseInt(process.env.DB_PORT ?? '5432', 10),
    username: process.env.POSTGRES_USER,
    password: process.env.POSTGRES_PASSWORD,
    database: process.env.POSTGRES_DB,
  };
});
