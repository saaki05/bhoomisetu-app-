module.exports = {
  env: {
    es2022: true,
    jest: true,
    node: true,
  },
  extends: ['eslint:recommended'],
  parserOptions: {
    ecmaVersion: 'latest',
    sourceType: 'script',
  },
  rules: {
    'no-console': 'off',
  },
};
