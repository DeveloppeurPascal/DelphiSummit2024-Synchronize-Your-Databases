DROP INDEX contacts_email;

DROP INDEX contacts_name;

DROP INDEX contacts_phone;

ALTER TABLE contacts
  ADD Sync_Delete BIT NOT NULL DEFAULT 0;

ALTER TABLE contacts
  ADD Sync_Changed BIT NOT NULL DEFAULT 1;

ALTER TABLE contacts
  ADD Sync_Code INTEGER NOT NULL DEFAULT 0;

ALTER TABLE contacts
  ADD Sync_ChangedDate DATETIME NULL;

ALTER TABLE contacts
  ADD Sync_NoSeq INTEGER NOT NULL DEFAULT 0;

CREATE UNIQUE INDEX contacts_email ON contacts
  (Sync_Delete,email,code);

CREATE UNIQUE INDEX contacts_phone ON contacts
  (Sync_Delete,phone,code);

CREATE UNIQUE INDEX contacts_sync_changed ON contacts
  (Sync_Changed,code);

CREATE UNIQUE INDEX contacts_sync_code ON contacts
  (Sync_Code,code);

CREATE UNIQUE INDEX contacts_name ON contacts
  (Sync_Delete,name,firstname,code);

CREATE INDEX contacts_deleted ON contacts
  (Sync_Delete,code);
