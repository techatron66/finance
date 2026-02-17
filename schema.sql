PRAGMA foreign_keys = ON;

-- =========================
-- USERS TABLE
-- =========================
CREATE TABLE users (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    username TEXT NOT NULL UNIQUE,
    hash TEXT NOT NULL
);

-- =========================
-- BALANCE TABLE
-- =========================
CREATE TABLE balance (
    u_id INTEGER PRIMARY KEY,
    balance REAL NOT NULL DEFAULT 0.00,
    FOREIGN KEY (u_id) REFERENCES users(id) ON DELETE CASCADE
);

-- =========================
-- PORTFOLIO TABLE
-- =========================
CREATE TABLE portfolio (
    p_id INTEGER PRIMARY KEY AUTOINCREMENT,
    u_id INTEGER NOT NULL,
    symbol TEXT NOT NULL,
    shares INTEGER NOT NULL DEFAULT 0,
    FOREIGN KEY (u_id) REFERENCES users(id) ON DELETE CASCADE
);

-- =========================
-- TRANSACTIONS TABLE
-- =========================
CREATE TABLE transactions (
    transaction_id INTEGER PRIMARY KEY AUTOINCREMENT,
    u_id INTEGER NOT NULL,
    symbol TEXT NOT NULL,
    shares INTEGER NOT NULL,
    price REAL NOT NULL,
    timestamp DATETIME DEFAULT CURRENT_TIMESTAMP,
    seller_id INTEGER,
    FOREIGN KEY (u_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (seller_id) REFERENCES users(id) ON DELETE SET NULL
);

-- =========================
-- SHARES TABLE
-- =========================
CREATE TABLE shares (
    symbol TEXT PRIMARY KEY,
    price REAL NOT NULL,
    last_updated DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- =========================
-- INDEXES
-- =========================
CREATE INDEX idx_portfolio_user ON portfolio(u_id);
CREATE INDEX idx_portfolio_symbol ON portfolio(symbol);
CREATE INDEX idx_transactions_user ON transactions(u_id);
CREATE INDEX idx_transactions_symbol ON transactions(symbol);
CREATE INDEX idx_transactions_timestamp ON transactions(timestamp);