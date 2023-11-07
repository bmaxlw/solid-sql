-- BigQuery syntax

CREATE OR REPLACE TABLE sol1dgate.tables.orders ( 
  id int64,
  uploaded_at timestamp,
  created_at timestamp, 
  updated_at timestamp, 
);

CREATE OR REPLACE TABLE sol1dgate.tables.transactions ( 
  id int64,
  order_id int64,
  uploaded_at timestamp,
  created_at timestamp, 
  updated_at timestamp, 
);

CREATE OR REPLACE TABLE sol1dgate.tables.verification ( 
  id int64,
  transaction_id int64,
  uploaded_at timestamp,
  created_at timestamp, 
  updated_at timestamp, 
);

INSERT INTO sol1dgate.tables.orders (id, uploaded_at, created_at, updated_at)
VALUES
  (1, TIMESTAMP '2023-11-05 12:00:00', TIMESTAMP '2023-11-05 11:00:00', TIMESTAMP '2023-11-05 11:00:00'),
  (2, TIMESTAMP '2023-11-05 13:00:00', TIMESTAMP '2023-11-05 12:00:00', TIMESTAMP '2023-11-05 12:00:00'),
  (3, TIMESTAMP '2023-11-05 14:00:00', TIMESTAMP '2023-11-05 13:00:00', TIMESTAMP '2023-11-05 13:00:00'),
  (4, TIMESTAMP '2023-11-05 15:00:00', TIMESTAMP '2023-11-05 14:00:00', TIMESTAMP '2023-11-05 14:00:00'),
  (5, TIMESTAMP '2023-11-05 16:00:00', TIMESTAMP '2023-11-05 15:00:00', TIMESTAMP '2023-11-05 15:00:00');

INSERT INTO sol1dgate.tables.transactions (id, order_id, uploaded_at, created_at, updated_at)
VALUES
  (1, 1, TIMESTAMP '2023-11-05 13:00:00', TIMESTAMP '2023-11-05 12:00:00', TIMESTAMP '2023-11-05 12:00:00'),
  (2, 2, TIMESTAMP '2023-11-05 14:00:00', TIMESTAMP '2023-11-05 13:00:00', TIMESTAMP '2023-11-05 13:00:00'),
  (3, 3, TIMESTAMP '2023-11-05 15:00:00', TIMESTAMP '2023-11-05 14:00:00', TIMESTAMP '2023-11-05 14:00:00'),
  (4, 4, TIMESTAMP '2023-11-05 16:00:00', TIMESTAMP '2023-11-05 15:00:00', TIMESTAMP '2023-11-05 15:00:00'),
  (5, 5, TIMESTAMP '2023-11-05 17:00:00', TIMESTAMP '2023-11-05 16:00:00', TIMESTAMP '2023-11-05 16:00:00');

INSERT INTO sol1dgate.tables.verification (id, transaction_id, uploaded_at, created_at, updated_at)
VALUES
  (1, 1, TIMESTAMP '2023-11-05 14:00:00', TIMESTAMP '2023-11-05 13:00:00', TIMESTAMP '2023-11-05 13:00:00'),
  (2, 2, TIMESTAMP '2023-11-05 15:00:00', TIMESTAMP '2023-11-05 14:00:00', TIMESTAMP '2023-11-05 14:00:00'),
  (3, 3, TIMESTAMP '2023-11-05 16:00:00', TIMESTAMP '2023-11-05 15:00:00', TIMESTAMP '2023-11-05 15:00:00'),
  (4, 4, TIMESTAMP '2023-11-05 17:00:00', TIMESTAMP '2023-11-05 16:00:00', TIMESTAMP '2023-11-05 16:00:00'),
  (5, 5, TIMESTAMP '2023-11-05 18:00:00', TIMESTAMP '2023-11-05 17:00:00', TIMESTAMP '2023-11-05 17:00:00');

CREATE OR REPLACE TABLE sol1dgate.tables.purchases ( 
  order_id int64,
  transaction_id int64,
  verification_id int64,
  uploaded_at timestamp
);

-- If (uploaded_at < created_at) !possible && (updated_at > uploaded_at) possible.
SELECT
    orders.id       order_id,
    transactions.id transaction_id,
    verification.id verification_id,
    current_timestamp()
FROM sol1dgate.tables.orders
LEFT JOIN sol1dgate.tables.transactions 
  ON orders.id = transactions.order_id
LEFT JOIN sol1dgate.tables.verification 
  ON transactions.id = verification.transaction_id
WHERE 
  (
    orders.uploaded_at > (SELECT COALESCE(MAX(p.uploaded_at), '1900-01-01') FROM sol1dgate.tables.purchases p)
    OR transactions.uploaded_at > (SELECT COALESCE(MAX(p.uploaded_at), '1900-01-01') FROM sol1dgate.tables.purchases p)
    OR verification.uploaded_at > (SELECT COALESCE(MAX(p.uploaded_at), '1900-01-01') FROM sol1dgate.tables.purchases p)
  ) 
  OR
  (
    orders.updated_at > (SELECT COALESCE(MAX(p.uploaded_at), '1900-01-01') FROM sol1dgate.tables.purchases p)
    OR transactions.updated_at > (SELECT COALESCE(MAX(p.uploaded_at), '1900-01-01') FROM sol1dgate.tables.purchases p)
    OR verification.updated_at > (SELECT COALESCE(MAX(p.uploaded_at), '1900-01-01') FROM sol1dgate.tables.purchases p)
  );
