unit fMain;

interface

uses
  System.SysUtils,
  System.Types,
  System.UITypes,
  System.Classes,
  System.Variants,
  FMX.Types,
  FMX.Controls,
  FMX.Forms,
  FMX.Graphics,
  FMX.Dialogs,
  FMX.Memo.Types,
  FMX.StdCtrls,
  FMX.Layouts,
  FMX.Controls.Presentation,
  FMX.ScrollBox,
  FMX.Memo,
  FMX.ListBox,
  FMX.TreeView,
  FireDAC.Stan.Intf,
  FireDAC.Stan.Option,
  FireDAC.Stan.Param,
  FireDAC.Stan.Error,
  FireDAC.DatS,
  FireDAC.Phys.Intf,
  FireDAC.DApt.Intf,
  FireDAC.Stan.Async,
  FireDAC.DApt,
  Data.DB,
  FireDAC.Comp.DataSet,
  FireDAC.Comp.Client,
  Olf.TableDataSync,
  System.JSON;

type
  TfrmMain = class(TForm)
    lFolders: TLayout;
    lNotes: TLayout;
    lNoteDetail: TLayout;
    mmoDetail: TMemo;
    gplDetail: TGridPanelLayout;
    btnSave: TButton;
    btnCancel: TButton;
    tvFolders: TTreeView;
    gplFolders: TGridPanelLayout;
    btnAddSibling: TButton;
    btnAddChild: TButton;
    lbNotes: TListBox;
    gplNotes: TGridPanelLayout;
    btnAdd: TButton;
    btnDelete: TButton;
    ToolBar1: TToolBar;
    btnSync: TButton;
    procedure btnAddSiblingClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure btnAddChildClick(Sender: TObject);
    procedure tvFoldersChange(Sender: TObject);
    procedure lbNotesChange(Sender: TObject);
    procedure btnSyncClick(Sender: TObject);
    procedure btnAddClick(Sender: TObject);
    procedure btnCancelClick(Sender: TObject);
    procedure btnSaveClick(Sender: TObject);
  private
    procedure FillFoldersList;
    procedure FillNotesList(const FolderID: integer = 0);
    procedure AddFoldersChildren(const TV: TTreeView; const ParentID: integer;
      const ParentItem: TTreeViewItem = nil);
    procedure AddTreeViewItem(const ParentItem: TTreeViewItem;
      const ParentID: integer);
  protected
    FDBSync: TOlfTDSDatabase;
    procedure initTableDataSync;
    procedure onSessionOpen(SessionParams: TJSONObject);
  public
  end;

var
  frmMain: TfrmMain;

implementation

{$R *.fmx}

uses
  SimpleNotes.DB,
  Olf.RTL.GenRandomID;

{ TfrmMain }

procedure TfrmMain.AddFoldersChildren(const TV: TTreeView;
  const ParentID: integer; const ParentItem: TTreeViewItem);
var
  qry: TFDQuery;
  item: TTreeViewItem;
begin
  qry := TFDQuery.create(self);
  try
    qry.Connection := dmSimpleNotesDB.FDConnection1;
    qry.Open('select * from folder where parent_id=' + ParentID.ToString);
    while not qry.eof do
    begin
      item := TTreeViewItem.create(self);
      item.tag := qry.FieldByName('id').AsInteger;
      item.Text := qry.FieldByName('name').AsString;
      if assigned(ParentItem) then
        ParentItem.AddObject(item)
      else
        TV.AddObject(item);
      AddFoldersChildren(TV, item.tag, item);
      qry.next;
    end;
  finally
    qry.free;
  end;
end;

procedure TfrmMain.AddTreeViewItem(const ParentItem: TTreeViewItem;
  const ParentID: integer);
var
  item: TTreeViewItem;
begin
  item := TTreeViewItem.create(self);
  item.Text := TOlfRandomIDGenerator.getIDBase62(10);
  // TODO : replace by an InputQuery
  dmSimpleNotesDB.FDConnection1.ExecSQL
    ('insert into folder (name, parent_id) values (:name, :parentid)',
    [item.Text, ParentID]);
  item.tag := dmSimpleNotesDB.FDConnection1.ExecSQLScalar
    ('select last_insert_rowid()');
  if assigned(ParentItem) then
    ParentItem.AddObject(item)
  else
    tvFolders.AddObject(item);
end;

procedure TfrmMain.btnAddChildClick(Sender: TObject);
var
  ParentID: integer;
  ParentItem: TTreeViewItem;
begin
  if assigned(tvFolders.Selected) then
  begin
    ParentItem := tvFolders.Selected;
    if assigned(ParentItem) then
      ParentID := ParentItem.tag
    else
      ParentID := 0;
    AddTreeViewItem(ParentItem, ParentID);
  end;
end;

procedure TfrmMain.btnAddClick(Sender: TObject);
var
  item: TListBoxItem;
begin
  if assigned(tvFolders.Selected) then
  begin
    item := TListBoxItem.create(self);
    item.TagString := TOlfRandomIDGenerator.getIDBase62(100);
    item.Text := item.TagString.Substring(0, 30);
    dmSimpleNotesDB.FDConnection1.ExecSQL
      ('insert into item (content, folder_id) values (:content, :folderid)',
      [item.TagString, tvFolders.Selected.tag]);
    item.tag := dmSimpleNotesDB.FDConnection1.ExecSQLScalar
      ('select last_insert_rowid()');
    lbNotes.AddObject(item);
  end;
end;

procedure TfrmMain.btnAddSiblingClick(Sender: TObject);
var
  item: TTreeViewItem;
  ParentID: integer;
  ParentItem: TTreeViewItem;
begin
  if assigned(tvFolders.Selected) then
    ParentItem := tvFolders.Selected.ParentItem
  else
    ParentItem := nil;
  if assigned(ParentItem) then
    ParentID := ParentItem.tag
  else
    ParentID := 0;
  AddTreeViewItem(ParentItem, ParentID);
end;

procedure TfrmMain.btnCancelClick(Sender: TObject);
begin
  mmoDetail.Text := mmoDetail.TagString;
end;

procedure TfrmMain.btnSaveClick(Sender: TObject);
begin
  dmSimpleNotesDB.FDConnection1.ExecSQL
    ('update item set content=:content, sync_maj=1 where id=' +
    mmoDetail.tag.ToString, [mmoDetail.Text]);
  mmoDetail.TagString := mmoDetail.Text;
end;

procedure TfrmMain.btnSyncClick(Sender: TObject);
begin
  if assigned(FDBSync) and not(FDBSync.SyncState = TOlfTDSSyncState.Started)
  then
  begin
    btnSync.Enabled := false;
    tthread.CreateAnonymousThread(
      procedure
      begin
        dmSimpleNotesDB.FDConnection1.ExecSQL
          ('update folder set sync_majdate=:date where sync_maj=1', [now]);
        dmSimpleNotesDB.FDConnection1.ExecSQL
          ('update item set sync_majdate=:date where sync_maj=1', [now]);
        FDBSync.Start;
        tthread.Queue(nil,
          procedure
          var
            qry: TFDQuery;
            id: integer;
          begin
            // Little patch for DelphiSummit : I didn't clone the good git branch for the synchronisation library
            qry := TFDQuery.create(self);
            try
              qry.Connection := dmSimpleNotesDB.FDConnection1;
              qry.Open('select parent_id from folder where (sync_parent_id=0) and (parent_id<>0)');
              while not qry.eof do
              begin
                id := dmSimpleNotesDB.FDConnection1.ExecSQLScalar
                  ('select sync_id from folder where id=' +
                  qry.FieldByName('parent_id').AsString);
                dmSimpleNotesDB.FDConnection1.ExecSQL
                  ('update folder set sync_parent_id=' + id.ToString +
                  ', sync_maj=1 where (parent_id=' +
                  qry.FieldByName('parent_id').AsString +
                  ') and (sync_parent_id=0)');
                qry.next;
              end;
            finally
              qry.free;
            end;
            qry := TFDQuery.create(self);
            try
              qry.Connection := dmSimpleNotesDB.FDConnection1;
              qry.Open('select folder_id from item where (folder_sync_id=0) and (folder_id<>0)');
              while not qry.eof do
              begin
                id := dmSimpleNotesDB.FDConnection1.ExecSQLScalar
                  ('select sync_id from folder where id=' +
                  qry.FieldByName('folder_id').AsString);
                dmSimpleNotesDB.FDConnection1.ExecSQL
                  ('update item set folder_sync_id=' + id.ToString +
                  ', sync_maj=1 where (folder_id=' +
                  qry.FieldByName('folder_id').AsString +
                  ') and (folder_sync_id=0)');
                qry.next;
              end;
            finally
              qry.free;
            end;

            // TODO : check if current mmo value has changed or not before removing it
            FillFoldersList;
            btnSync.Enabled := true;
          end);
      end).Start;
  end;
end;

procedure TfrmMain.FillFoldersList;
begin
  tvFolders.tag := -1;
  try
    tvFolders.Clear;
    AddFoldersChildren(tvFolders, 0, nil);
  finally
    tvFolders.tag := 0;
  end;
  FillNotesList;
end;

procedure TfrmMain.FillNotesList(const FolderID: integer);
var
  qry: TFDQuery;
  item: TListBoxItem;
begin
  lbNotes.tag := -1;
  try
    lbNotes.Clear;
    qry := TFDQuery.create(self);
    try
      qry.Connection := dmSimpleNotesDB.FDConnection1;
      qry.Open('select * from item where folder_id=' + FolderID.ToString);
      while not qry.eof do
      begin
        item := TListBoxItem.create(self);
        item.tag := qry.FieldByName('id').AsInteger;
        item.TagString := qry.FieldByName('content').AsString;
        item.Text := item.TagString.Substring(0, 30);
        lbNotes.AddObject(item);
        qry.next;
      end;
    finally
      qry.free;
    end;
  finally
    lbNotes.tag := 0;
  end;
  mmoDetail.Text := '';
  mmoDetail.TagString := mmoDetail.Text;
  mmoDetail.tag := 0;
end;

procedure TfrmMain.FormCreate(Sender: TObject);
begin
  FillFoldersList;

  initTableDataSync;
end;

procedure TfrmMain.initTableDataSync;
var
  Tab: TOlfTDSTable;
begin
  FDBSync := TOlfTDSDatabase.create(self);
  FDBSync.SyncMode := TOlfTDSSyncMode.Manual;
  FDBSync.onSessionOpen := onSessionOpen;
  FDBSync.ServerProtocol := TOlfTDSServerProtocol.HTTP;
{$IFDEF DEBUG}
{$IFDEF MACOS}
  FDBSync.ServerIPOrDomain := '92.222.216.2';
{$ELSE}
  FDBSync.ServerIPOrDomain := '127.0.0.1';
{$ENDIF}
{$ELSE}
  FDBSync.ServerIPOrDomain := '92.222.216.2';
{$ENDIF}
  FDBSync.ServerPort := 8081;
  FDBSync.ServerFolder := '/';
  FDBSync.DefaultChangedFieldName := 'sync_maj';
  FDBSync.DefaultChangedDateTimeFieldName := 'sync_majdate';
  FDBSync.DefaultNoSeqFieldName := 'sync_level';
  FDBSync.LocalConnectionDefName := dmSimpleNotesDB.getConnectionDefName;

  Tab := TOlfTDSTable.create(self);
  Tab.TableName := 'folder';
  Tab.AddKey(TOlfTDSField.create('id', 'sync_id'));
  Tab.AddForeignKey(TOlfTDSForeignKey.create(TOlfTDSField.create('parent_id',
    'sync_parent_id'), Tab.TableName, TOlfTDSField.create('id', 'sync_id')));
  Tab.Database := FDBSync;
  Tab.SyncType := TOlfTDSSyncType.Mirroring;
  Tab.TableDeleteType := TOlfTDSTableDeleteType.Physical;
  // TODO : add the delete sync table to manage physical deletions

  Tab := TOlfTDSTable.create(self);
  Tab.TableName := 'item';
  Tab.AddKey(TOlfTDSField.create('id', 'sync_id'));
  Tab.AddForeignKey(TOlfTDSForeignKey.create(TOlfTDSField.create('folder_id',
    'folder_sync_id'), 'folder', TOlfTDSField.create('id', 'sync_id')));
  Tab.Database := FDBSync;
  Tab.SyncType := TOlfTDSSyncType.Mirroring;
  Tab.TableDeleteType := TOlfTDSTableDeleteType.Physical;
end;

procedure TfrmMain.lbNotesChange(Sender: TObject);
begin
  if (not(lbNotes.tag < 0)) and assigned(lbNotes.Selected) then
  begin
    // TODO : check if current memo content have changed before going to the new one
    mmoDetail.Text := lbNotes.Selected.TagString;
    mmoDetail.TagString := mmoDetail.Text;
    mmoDetail.tag := lbNotes.Selected.tag;
  end;
end;

procedure TfrmMain.onSessionOpen(SessionParams: TJSONObject);
begin
  SessionParams.AddPair('user', 'MyUser');
  SessionParams.AddPair('password', 'MyPassword');
  SessionParams.AddPair('dbAlias', dmSimpleNotesDB.Name);
end;

procedure TfrmMain.tvFoldersChange(Sender: TObject);
begin
  if (not(tvFolders.tag < 0)) and assigned(tvFolders.Selected) then
    FillNotesList(tvFolders.Selected.tag);
end;

initialization

{$IFDEF DEBUG}
  ReportMemoryLeaksOnShutdown := true;
{$ENDIF}

end.
