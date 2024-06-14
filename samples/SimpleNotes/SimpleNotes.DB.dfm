object dmSimpleNotesDB: TdmSimpleNotesDB
  OnCreate = DataModuleCreate
  Height = 480
  Width = 640
  object FDConnection1: TFDConnection
    Params.Strings = (
      'LockingMode=Normal'
      'DriverID=SQLite')
    LoginPrompt = False
    AfterConnect = FDConnection1AfterConnect
    BeforeConnect = FDConnection1BeforeConnect
    Left = 312
    Top = 136
  end
  object FDScript1: TFDScript
    SQLScripts = <
      item
        Name = 'v1'
        SQL.Strings = (
          'CREATE TABLE item ('
          '  id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,'
          '  content TEXT NULL DEFAULT "",'
          '  folder_id INTEGER NULL DEFAULT 0'
          ');'
          ''
          'CREATE TABLE folder ('
          '  id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,'
          '  name VARCHAR(255) NULL DEFAULT ""'
          ');'
          ''
          'CREATE UNIQUE INDEX item_folder ON item'
          '  (folder_id,id);'
          ''
          'CREATE UNIQUE INDEX folder_name ON folder'
          '  (name,id);')
      end
      item
        Name = 'v1_to_v2'
        SQL.Strings = (
          'ALTER TABLE item'
          '  ADD folder_sync_id INTEGER NULL DEFAULT 0;'
          ''
          'ALTER TABLE item'
          '  ADD sync_id INTEGER NULL DEFAULT 0;'
          ''
          'ALTER TABLE item'
          '  ADD sync_level INTEGER NULL DEFAULT 0;'
          ''
          'ALTER TABLE item'
          '  ADD sync_majdate DATETIME NULL;'
          ''
          'ALTER TABLE item'
          '  ADD sync_maj BIT NULL DEFAULT 1;'
          ''
          'ALTER TABLE folder'
          '  ADD sync_maj BIT NULL DEFAULT 1;'
          ''
          'ALTER TABLE folder'
          '  ADD sync_level INTEGER NULL DEFAULT 0;'
          ''
          'ALTER TABLE folder'
          '  ADD sync_id INTEGER NULL DEFAULT 0;'
          ''
          'ALTER TABLE folder'
          '  ADD sync_majdate DATETIME NULL;'
          ''
          'CREATE UNIQUE INDEX item_foldersyncid ON item'
          '  (folder_sync_id,folder_id,id);'
          ''
          'CREATE UNIQUE INDEX item_syncmaj ON item'
          '  (sync_maj,id);'
          ''
          'CREATE UNIQUE INDEX item_synclevel ON item'
          '  (sync_level,id);'
          ''
          'CREATE UNIQUE INDEX item_syncid ON item'
          '  (sync_id,id);'
          ''
          'CREATE UNIQUE INDEX folder_syncid ON folder'
          '  (sync_id,id);'
          ''
          'CREATE UNIQUE INDEX folder_synclevel ON folder'
          '  (sync_level,id);'
          ''
          'CREATE UNIQUE INDEX folder_syncmaj ON folder'
          '  (sync_maj,id);')
      end
      item
        Name = 'v2_to_v3'
        SQL.Strings = (
          'ALTER TABLE folder'
          '  ADD sync_parent_id INTEGER NULL DEFAULT 0;'
          ''
          'ALTER TABLE folder'
          '  ADD parent_id INTEGER NULL DEFAULT 0;'
          ''
          'CREATE UNIQUE INDEX folder_syncparent ON folder'
          '  (sync_parent_id,id);'
          ''
          'CREATE UNIQUE INDEX folder_parent ON folder'
          '  (parent_id,id);')
      end>
    Connection = FDConnection1
    Params = <>
    Macros = <>
    Left = 168
    Top = 176
  end
  object FDPhysSQLiteDriverLink1: TFDPhysSQLiteDriverLink
    Left = 192
    Top = 328
  end
  object FDGUIxWaitCursor1: TFDGUIxWaitCursor
    Provider = 'Console'
    Left = 368
    Top = 296
  end
end
