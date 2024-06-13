ALTER TABLE todos
  ADD sync_maj BIT NULL DEFAULT 1;

ALTER TABLE todos
  ADD sync_majdate DATETIME NULL;

ALTER TABLE todos
  ADD sync_id INTEGER NULL DEFAULT 0;

ALTER TABLE todos
  ADD sync_level INTEGER NULL DEFAULT 0;

CREATE UNIQUE INDEX par_maj ON todos
  (sync_maj,id);

CREATE UNIQUE INDEX par_syncid ON todos
  (sync_id,id);

CREATE UNIQUE INDEX par_synclevel ON todos
  (sync_level,id);
