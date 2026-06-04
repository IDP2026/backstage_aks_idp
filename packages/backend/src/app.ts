import express, { Request, Response } from 'express';
import { createServiceBuilder } from '@backstage/backend-common';
import { Logger } from 'winston';

export interface BackendInitializer {
  logger: Logger;
}

export async function createApp({ logger: _logger }: BackendInitializer) {
  const router = express.Router();

  router.get('/health', (_req: Request, res: Response) => {
    res.json({ status: 'ok' });
  });

  const service = createServiceBuilder(module)
    .setPort(7007)
    .addRouter('/', router as any);

  return service;
}

