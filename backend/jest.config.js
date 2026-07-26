module.exports = {
  testEnvironment: 'node',
  setupFiles: ['./tests/setup.js'],
  collectCoverageFrom: ['src/**/*.js'],
  coverageDirectory: 'coverage',
  testPathIgnorePatterns: ['/node_modules/'],
};
