# ![alt text](<Screenshot 2026-02-18 at 12.41.02 AM.png>)

This document describes the structure, relationships, and purpose of each table in `finance.db`, a SQLite database built for a dummy stock trading application.

---

## Overview

The database models a simplified stock trading platform where users can maintain an account balance, hold a portfolio of stocks, and execute buy/sell transactions with one another. It consists of five tables: `users`, `balance`, `portfolio`, `transactions`, and `shares`.

---


## E-R diagram
![alt text](<Screenshot 2026-02-18 at 12.20.59 AM.png>)
![alt text](<Screenshot 2026-02-18 at 12.20.12 AM.png>)

---

## Tables

### `users`
Stores the registered users of the platform.

| Column     | Type    | Description |
|------------|---------|-------------|
| `id`       | INTEGER | Primary key, auto-incremented unique identifier for each user. |
| `hash`     | TEXT    | Hashed password for authentication. The raw password is never stored. |
| `name`     | TEXT    | Full display name of the user. |
| `username` | TEXT    | Login username chosen by the user. |

This table serves as the central reference point — every other table links back to `users` via `u_id` or `seller_id` foreign keys.

---

### `balance`
Tracks the cash balance available to each user for trading.

| Column    | Type    | Description |
|-----------|---------|-------------|
| `u_id`    | INTEGER | Primary key and foreign key referencing `users(id)`. One balance record per user. |
| `balance` | REAL    | Current cash balance of the user, defaulting to `0.00`. |

The one-to-one relationship with `users` is enforced by using `u_id` as the primary key itself, ensuring no user can have more than one balance entry. If a user is deleted, their balance record is automatically removed via `ON DELETE CASCADE`.

---

### `portfolio`
Represents the current stock holdings of each user — i.e., what stocks they own and how many shares.

| Column   | Type    | Description |
|----------|---------|-------------|
| `p_id`   | INTEGER | Primary key, auto-incremented. |
| `u_id`   | INTEGER | Foreign key referencing `users(id)`. Links the holding to its owner. |
| `symbol` | TEXT    | The stock ticker symbol (e.g., `AAPL`, `TSLA`). |
| `shares` | INTEGER | Number of shares currently held for that symbol, defaulting to `0`. |

A user can have multiple rows in this table — one for each distinct stock they hold. Together, these rows make up their complete portfolio. Cascade delete ensures holdings are cleaned up if the user account is removed.

---

### `transactions`
The core activity log of the platform. Every buy or sell action is recorded here, capturing who bought, who sold, what stock, how many shares, and at what price.

| Column           | Type     | Description |
|------------------|----------|-------------|
| `transaction_id` | INTEGER  | Primary key, auto-incremented unique ID for each transaction. |
| `u_id`           | INTEGER  | Foreign key referencing `users(id)`. Represents the **buyer** in the transaction. |
| `symbol`         | TEXT     | The stock ticker symbol involved in the transaction. |
| `shares`         | INTEGER  | Number of shares exchanged. |
| `price`          | REAL     | Price per share at the time of the transaction. |
| `timestamp`      | DATETIME | Date and time the transaction occurred, defaulting to the current time. |
| `seller_id`      | INTEGER  | Foreign key referencing `users(id)`. Represents the **seller** in the transaction. Can be `NULL` for market purchases with no specific seller. |

When a user is deleted, their transactions as a buyer are cascaded and removed (`ON DELETE CASCADE`). However, if a seller is deleted, the `seller_id` is simply set to `NULL` (`ON DELETE SET NULL`) rather than deleting the transaction record — preserving the transaction history for the buyer.

---

### `shares`
A lookup table that stores the current price of each stock symbol available on the platform.

| Column         | Type     | Description |
|----------------|----------|-------------|
| `symbol`       | TEXT     | Primary key. The stock ticker symbol (e.g., `GOOGL`, `MSFT`). |
| `price`        | REAL     | Current price per share for the symbol. |
| `last_updated` | DATETIME | Timestamp of the last price update, defaulting to the current time. |

> **Note:** In this assignment, the `shares` table is populated with **dummy/static values** for testing purposes. In a real-world application, this table would not be maintained manually. Instead, it would be kept up to date by periodically fetching live stock price data from a financial market API (such as Yahoo Finance, Alpha Vantage, or IEX Cloud), ensuring that trades always reflect accurate, real-time pricing.

---

## Relationships

```
users ──────────────── balance        (one-to-one)
  │
  ├──────────────────── portfolio      (one-to-many: a user holds many stocks)
  │
  ├── u_id ────────────transactions   (one-to-many: a user makes many purchases)
  │
  └── seller_id ───────transactions   (one-to-many: a user can be the seller in many transactions)

shares ──────────────── (referenced by symbol in portfolio and transactions)
```

- **`users → balance`**: Each user has exactly one balance record.
- **`users → portfolio`**: Each user can hold multiple stock positions.
- **`users → transactions` (as buyer)**: Each user can have many transaction records as the purchasing party.
- **`users → transactions` (as seller)**: A user can also appear as the seller in transactions made by others.
- **`shares`**: Acts as a reference/pricing table, linked logically by `symbol` to both `portfolio` and `transactions`, though not enforced as a hard foreign key constraint.

---

## Cascading Behavior Summary

| Event | Affected Table | Behavior |
|---|---|---|
| User deleted | `balance` | Row deleted |
| User deleted | `portfolio` | Rows deleted |
| User deleted | `transactions` (as buyer) | Rows deleted |
| Seller deleted | `transactions` (as seller) | `seller_id` set to `NULL` |
