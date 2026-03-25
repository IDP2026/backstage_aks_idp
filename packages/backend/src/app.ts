import { createServiceBuilder } from '@backstage/backend-common';
import { Logger } from 'winston';

export interface BackendInitializer {
  logger: Logger;
}

export async function createApp({ logger }: BackendInitializer) {
  const service = createServiceBuilder(module)
    .setPort(7007)
    .addRouter('/health', (req, res) => res.json({ status: 'ok' }));

  return service;
}
