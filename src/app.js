import express from 'express';
import logger from '#config/logger.js';

const app = express();

app.get('/', (req, res) => {
  logger.info('Root endpoint accessed');
  res.status(200).send('Hello, World!');
});

export default app;
