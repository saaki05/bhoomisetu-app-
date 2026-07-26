const swaggerJsdoc = require('swagger-jsdoc');
const { loadEnv } = require('./env');

const env = loadEnv();

const swaggerSpec = swaggerJsdoc({
  definition: {
    openapi: '3.0.3',
    info: {
      title: 'BhoomiSetu API',
      version: '1.0.0',
      description: 'REST API powering the BhoomiSetu agricultural trade and farming assistance platform.',
    },
    servers: [{ url: env.API_BASE_URL, description: env.NODE_ENV }],
    components: {
      securitySchemes: {
        bearerAuth: { type: 'http', scheme: 'bearer', bearerFormat: 'JWT' },
      },
    },
    security: [{ bearerAuth: [] }],
  },
  apis: ['./src/routes/*.js', './src/docs/*.yaml'],
});

module.exports = swaggerSpec;
