-- migrate:up
ALTER TABLE address ADD INDEX idx_postal_code (postal_code);

-- migrate:down
ALTER TABLE address DROP INDEX idx_postal_code;
