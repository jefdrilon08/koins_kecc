## Testing Indices

```
DROP INDEX manual_idx_1;
CREATE INDEX manual_idx_1 ON account_transactions (subsidiary_id, transacted_at) WHERE transaction_type IN ('deposit', 'withdraw');
DROP INDEX manual_idx_2;
CREATE INDEX manual_idx_2 ON monthly_closing_collections (closing_date DESC);
DROP INDEX manual_idx_3;
CREATE INDEX manual_idx_3 ON monthly_closing_collections (branch_id, closing_date DESC);
DROP INDEX manual_idx_4;
CREATE INDEX manual_idx_4 ON activity_logs (created_at DESC);
DROP INDEX manual_idx_5;
CREATE INDEX manual_idx_5 ON data_stores (status, (meta->>'data_store_type'), (meta->>'branch_id'), (meta->>'as_of') DESC);
DROP INDEX manual_idx_6;
CREATE INDEX manual_idx_6 ON loan_products (priority ASC);
DROP INDEX manual_idx_7;
CREATE INDEX manual_idx_7 ON members (status, center_id);
```
