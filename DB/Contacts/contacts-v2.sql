CREATE TABLE contacts (
  code INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
  Sync_Code INTEGER NOT NULL DEFAULT 0,
  name VARCHAR(255) NOT NULL DEFAULT "",
  firstname VARCHAR(255) NOT NULL DEFAULT "",
  phone VARCHAR(255) NOT NULL DEFAULT "",
  email VARCHAR(255) NOT NULL DEFAULT "",
  Sync_Changed BIT NOT NULL DEFAULT 1,
  Sync_ChangedDate DATETIME NULL,
  Sync_NoSeq INTEGER NOT NULL DEFAULT 0,
  Sync_Delete BIT NOT NULL DEFAULT 0
);

CREATE UNIQUE INDEX contacts_sync_code ON contacts
  (Sync_Code,code);

CREATE UNIQUE INDEX contacts_sync_changed ON contacts
  (Sync_Changed,code);

CREATE INDEX contacts_deleted ON contacts
  (Sync_Delete,code);

CREATE UNIQUE INDEX contacts_name ON contacts
  (Sync_Delete,name,firstname,code);

CREATE UNIQUE INDEX contacts_phone ON contacts
  (Sync_Delete,phone,code);

CREATE UNIQUE INDEX contacts_email ON contacts
  (Sync_Delete,email,code);
