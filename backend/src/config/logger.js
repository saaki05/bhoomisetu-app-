const winston = require('winston');
const { loadEnv } = require('./env');

const env = loadEnv();

const logger = winston.createLogger({
  level: env.LOG_LEVEL,
  format: winston.format.combine(
    winston.format.timestamp(),
    winston.format.errors({ stack: true }),
    env.NODE_ENV === 'production' ? winston.format.json() : winston.format.combine(
      winston.format.colorize(),
      winston.format.printf(({ timestamp, level, message, stack, ...meta }) => {
        const metaStr = Object.keys(meta).length ? ` ${JSON.stringify(meta)}` : '';
        return `${timestamp} [${level}] ${stack || message}${metaStr}`;
      }),
    ),
  ),
  transports: [new winston.transports.Console()],
});

module.exports = logger;
