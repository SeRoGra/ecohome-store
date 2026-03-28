const { Pool } = require('pg');

const pool = new Pool({
  host:     process.env.DB_HOST     || 'localhost',
  port:     process.env.DB_PORT     || 5432,
  database: process.env.DB_NAME     || 'ecohome_chat',
  user:     process.env.DB_USER     || 'ecohome_user',
  password: process.env.DB_PASSWORD || 'ecohome_pass',
  max: 20,
});

const query = (text, params) => pool.query(text, params);

module.exports = { pool, query };
