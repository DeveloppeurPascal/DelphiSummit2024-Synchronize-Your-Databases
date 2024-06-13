object dmContactsDB: TdmContactsDB
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
    Left = 128
    Top = 64
  end
  object FDScript1: TFDScript
    SQLScripts = <
      item
        Name = 'v1'
        SQL.Strings = (
          'CREATE TABLE contacts ('
          '  code INTEGER PRIMARY KEY AUTOINCREMENT,'
          '  name VARCHAR(255) DEFAULT "",'
          '  firstname VARCHAR(255) DEFAULT "",'
          '  phone VARCHAR(255) DEFAULT "",'
          '  email VARCHAR(255) DEFAULT ""'
          ');'
          ''
          'CREATE UNIQUE INDEX contacts_email ON contacts'
          '  (email,code);'
          ''
          'CREATE UNIQUE INDEX contacts_phone ON contacts'
          '  (phone,code);'
          ''
          'CREATE UNIQUE INDEX contacts_name ON contacts'
          '  (name,firstname,code);')
      end
      item
        Name = 'v2'
        SQL.Strings = (
          'DROP INDEX contacts_email;'
          ''
          'DROP INDEX contacts_name;'
          ''
          'DROP INDEX contacts_phone;'
          ''
          'ALTER TABLE contacts'
          '  ADD Sync_Delete BIT DEFAULT 0;'
          ''
          'ALTER TABLE contacts'
          '  ADD Sync_Changed BIT DEFAULT 1;'
          ''
          'ALTER TABLE contacts'
          '  ADD Sync_Code INTEGER DEFAULT 0;'
          ''
          'ALTER TABLE contacts'
          '  ADD Sync_ChangedDate DATETIME NULL;'
          ''
          'ALTER TABLE contacts'
          '  ADD Sync_NoSeq INTEGER DEFAULT 0;'
          ''
          'CREATE UNIQUE INDEX contacts_email ON contacts'
          '  (Sync_Delete,email,code);'
          ''
          'CREATE UNIQUE INDEX contacts_phone ON contacts'
          '  (Sync_Delete,phone,code);'
          ''
          'CREATE UNIQUE INDEX contacts_sync_changed ON contacts'
          '  (Sync_Changed,code);'
          ''
          'CREATE UNIQUE INDEX contacts_sync_code ON contacts'
          '  (Sync_Code,code);'
          ''
          'CREATE UNIQUE INDEX contacts_name ON contacts'
          '  (Sync_Delete,name,firstname,code);'
          ''
          'CREATE INDEX contacts_deleted ON contacts'
          '  (Sync_Delete,code);')
      end>
    Connection = FDConnection1
    Params = <>
    Macros = <>
    FetchOptions.AssignedValues = [evItems, evAutoClose, evAutoFetchAll]
    FetchOptions.AutoClose = False
    FetchOptions.Items = [fiBlobs, fiDetails]
    ResourceOptions.AssignedValues = [rvMacroCreate, rvMacroExpand, rvDirectExecute, rvPersistent]
    ResourceOptions.MacroCreate = False
    ResourceOptions.DirectExecute = True
    Left = 128
    Top = 160
  end
  object FDPhysSQLiteDriverLink1: TFDPhysSQLiteDriverLink
    Left = 272
    Top = 64
  end
  object FDGUIxWaitCursor1: TFDGUIxWaitCursor
    Provider = 'Console'
    Left = 472
    Top = 296
  end
end
