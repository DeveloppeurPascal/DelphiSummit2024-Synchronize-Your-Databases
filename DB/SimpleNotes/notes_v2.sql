CREATE TABLE item (
  id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
  sync_id INTEGER NULL DEFAULT 0,
  content TEXT NULL DEFAULT "",
  folder_id INTEGER NULL DEFAULT 0,
  folder_sync_id INTEGER NULL DEFAULT 0,
  sync_level INTEGER NULL DEFAULT 0,
  sync_maj BIT NULL DEFAULT 1,
  sync_majdate DATETIME NULL
);

CREATE TABLE folder (
  id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
  sync_id INTEGER NULL DEFAULT 0,
  name VARCHAR(255) NULL DEFAULT "",
  sync_level INTEGER NULL DEFAULT 0,
  sync_maj BIT NULL DEFAULT 1,
  sync_majdate DATETIME NULL
);

CREATE UNIQUE INDEX item_foldersyncid ON item
  (folder_sync_id,folder_id,id);

CREATE UNIQUE INDEX item_syncid ON item
  (sync_id,id);

CREATE UNIQUE INDEX item_synclevel ON item
  (sync_level,id);

CREATE UNIQUE INDEX item_syncmaj ON item
  (sync_maj,id);

CREATE UNIQUE INDEX item_folder ON item
  (folder_id,id);

CREATE UNIQUE INDEX folder_syncmaj ON folder
  (sync_maj,id);

CREATE UNIQUE INDEX folder_syncid ON folder
  (sync_id,id);

CREATE UNIQUE INDEX folder_name ON folder
  (name,id);

CREATE UNIQUE INDEX folder_synclevel ON folder
  (sync_level,id);
