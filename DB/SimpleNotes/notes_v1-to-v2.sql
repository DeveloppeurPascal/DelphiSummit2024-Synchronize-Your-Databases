ALTER TABLE item
  ADD folder_sync_id INTEGER NULL DEFAULT 0;

ALTER TABLE item
  ADD sync_id INTEGER NULL DEFAULT 0;

ALTER TABLE item
  ADD sync_level INTEGER NULL DEFAULT 0;

ALTER TABLE item
  ADD sync_majdate DATETIME NULL;

ALTER TABLE item
  ADD sync_maj BIT NULL DEFAULT 1;

ALTER TABLE folder
  ADD sync_maj BIT NULL DEFAULT 1;

ALTER TABLE folder
  ADD sync_level INTEGER NULL DEFAULT 0;

ALTER TABLE folder
  ADD sync_id INTEGER NULL DEFAULT 0;

ALTER TABLE folder
  ADD sync_majdate DATETIME NULL;

CREATE UNIQUE INDEX item_foldersyncid ON item
  (folder_sync_id,folder_id,id);

CREATE UNIQUE INDEX item_syncmaj ON item
  (sync_maj,id);

CREATE UNIQUE INDEX item_synclevel ON item
  (sync_level,id);

CREATE UNIQUE INDEX item_syncid ON item
  (sync_id,id);

CREATE UNIQUE INDEX folder_syncid ON folder
  (sync_id,id);

CREATE UNIQUE INDEX folder_synclevel ON folder
  (sync_level,id);

CREATE UNIQUE INDEX folder_syncmaj ON folder
  (sync_maj,id);
