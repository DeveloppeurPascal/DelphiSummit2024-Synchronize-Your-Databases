CREATE TABLE todos (
  id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
  sync_id INTEGER NULL DEFAULT 0,
  label VARCHAR(255) NULL DEFAULT "",
  done BIT NULL DEFAULT 0,
  sync_level INTEGER NULL DEFAULT 0,
  sync_maj BIT NULL DEFAULT 1,
  sync_majdate DATETIME NULL
);

CREATE UNIQUE INDEX par_syncid ON todos
  (sync_id,id);

CREATE UNIQUE INDEX par_maj ON todos
  (sync_maj,id);

CREATE UNIQUE INDEX par_synclevel ON todos
  (sync_level,id);

CREATE UNIQUE INDEX par_done_label ON todos
  (done,label,id);

CREATE UNIQUE INDEX par_label ON todos
  (label,id);
