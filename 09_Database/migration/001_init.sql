BEGIN;

CREATE EXTENSION IF NOT EXISTS pgcrypto;

\i ../Player.sql
\i ../World.sql
\i ../Weather.sql
\i ../Today.sql
\i ../Fish.sql
\i ../FishingSession.sql
\i ../Companion.sql
\i ../Relationship.sql
\i ../Meaning.sql
\i ../Story.sql
\i ../Memory.sql
\i ../Inventory.sql
\i ../Wallet.sql
\i ../Transaction.sql

COMMIT;

