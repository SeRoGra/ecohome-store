-- =============================================
-- EcoHome Chat - Inicializacion de base de datos
-- =============================================

-- Tabla de usuarios
CREATE TABLE IF NOT EXISTS users (
    id         BIGSERIAL    PRIMARY KEY,
    username   VARCHAR(100) NOT NULL UNIQUE,
    email      VARCHAR(200) NOT NULL UNIQUE,
    password   VARCHAR(255) NOT NULL,
    role       VARCHAR(50)  NOT NULL DEFAULT 'USER',
    created_at TIMESTAMP    NOT NULL DEFAULT NOW()
);
CREATE INDEX IF NOT EXISTS idx_users_username ON users(username);

-- password = 'password123' (BCrypt cost 12)
INSERT INTO users (username, email, password, role) VALUES
('ventas_admin',  'ventas@ecohome.co',    '$2a$12$T4lput4UbPcNAznwEBP4RejmQiddyOOh3AvDNzyyJZUR2C.sAe30.', 'VENTAS'),
('logistica_op',  'logistica@ecohome.co', '$2a$12$T4lput4UbPcNAznwEBP4RejmQiddyOOh3AvDNzyyJZUR2C.sAe30.', 'LOGISTICA'),
('soporte_01',    'soporte@ecohome.co',   '$2a$12$T4lput4UbPcNAznwEBP4RejmQiddyOOh3AvDNzyyJZUR2C.sAe30.', 'SOPORTE')
ON CONFLICT (username) DO NOTHING;

-- Tabla de mensajes
CREATE TABLE IF NOT EXISTS messages (
    id         BIGSERIAL    PRIMARY KEY,
    user_id    BIGINT       NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    username   VARCHAR(100) NOT NULL,
    text       TEXT         NOT NULL CHECK (length(text) > 0 AND length(text) <= 2000),
    created_at TIMESTAMP    NOT NULL DEFAULT NOW()
);
CREATE INDEX IF NOT EXISTS idx_messages_created_at ON messages(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_messages_user_id    ON messages(user_id);

-- Tabla de productos (Unidad 3: trazabilidad creador)
CREATE TABLE IF NOT EXISTS products (
    id          BIGSERIAL     PRIMARY KEY,
    name        VARCHAR(200)  NOT NULL,
    description TEXT,
    price       DECIMAL(10,2) NOT NULL CHECK (price >= 0),
    stock       INTEGER       NOT NULL DEFAULT 0 CHECK (stock >= 0),
    created_by  BIGINT        NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
    created_at  TIMESTAMP     NOT NULL DEFAULT NOW(),
    updated_at  TIMESTAMP     NOT NULL DEFAULT NOW()
);
CREATE INDEX IF NOT EXISTS idx_products_created_by ON products(created_by);

-- Seed: productos de ejemplo (se insertan solo si la tabla queda vacía)
INSERT INTO products (name, description, price, stock, created_by)
SELECT 'EcoBotella Acero 500ml', 'Botella reutilizable de acero inoxidable libre de BPA', 24.99, 100,
       (SELECT id FROM users WHERE username = 'ventas_admin')
WHERE NOT EXISTS (SELECT 1 FROM products);

INSERT INTO products (name, description, price, stock, created_by)
SELECT 'Set Cepillos Bambú x4', 'Cepillos de dientes biodegradables con cerdas de carbón', 14.99, 200,
       (SELECT id FROM users WHERE username = 'ventas_admin')
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'Set Cepillos Bambú x4');

INSERT INTO products (name, description, price, stock, created_by)
SELECT 'Bolsa Tela Orgánica', 'Bolsa reutilizable de algodón orgánico certificado', 9.99, 300,
       (SELECT id FROM users WHERE username = 'logistica_op')
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'Bolsa Tela Orgánica');

INSERT INTO products (name, description, price, stock, created_by)
SELECT 'Kit Pajitas Metal x6', 'Set de pajitas de acero inoxidable con limpiador incluido', 12.50, 150,
       (SELECT id FROM users WHERE username = 'soporte_01')
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'Kit Pajitas Metal x6');
