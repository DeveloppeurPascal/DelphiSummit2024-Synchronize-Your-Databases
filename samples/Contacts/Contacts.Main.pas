unit Contacts.Main;

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
  Contacts.DB,
  FireDAC.Stan.Intf,
  FireDAC.Stan.Option,
  FireDAC.Stan.Param,
  FireDAC.Stan.Error,
  FireDAC.DatS,
  FireDAC.Phys.Intf,
  FireDAC.DApt.Intf,
  FireDAC.Stan.Async,
  FireDAC.DApt,
  System.Rtti,
  FMX.Grid.Style,
  Data.Bind.EngExt,
  FMX.Bind.DBEngExt,
  FMX.Bind.Grid,
  System.Bindings.Outputs,
  FMX.Bind.Editors,
  Data.Bind.Components,
  Data.Bind.Grid,
  Data.Bind.DBScope,
  FMX.Controls.Presentation,
  FMX.ScrollBox,
  FMX.Grid,
  Data.DB,
  FireDAC.Comp.DataSet,
  FireDAC.Comp.Client,
  FMX.StdCtrls,
  FMX.Edit,
  FMX.Layouts,
  FMX.TabControl,
  Olf.TableDataSync,
  System.JSON;

type
  TfrmContactsMain = class(TForm)
    FDQuery1: TFDQuery;
    BindSourceDB1: TBindSourceDB;
    BindingsList1: TBindingsList;
    edtName: TEdit;
    edtFirstname: TEdit;
    edtEmail: TEdit;
    edtPhone: TEdit;
    TabControl1: TTabControl;
    tiList: TTabItem;
    tiRecord: TTabItem;
    ToolBar1: TToolBar;
    btnInsert: TButton;
    btnEdit: TButton;
    btnDelete: TButton;
    StringGrid1: TStringGrid;
    GridPanelLayout1: TGridPanelLayout;
    btnPost: TButton;
    btnCancel: TButton;
    LinkGridToDataSourceBindSourceDB1: TLinkGridToDataSource;
    btnForceSynchro: TButton;
    procedure FormCreate(Sender: TObject);
    procedure btnDeleteClick(Sender: TObject);
    procedure btnEditClick(Sender: TObject);
    procedure btnInsertClick(Sender: TObject);
    procedure btnPostClick(Sender: TObject);
    procedure btnCancelClick(Sender: TObject);
    procedure FDQuery1BeforePost(DataSet: TDataSet);
    procedure FDQuery1BeforeDelete(DataSet: TDataSet);
    procedure btnForceSynchroClick(Sender: TObject);
  private
  protected
    FDBSync: TOlfTDSDatabase;
    procedure initTableDataSync;
    procedure onSessionOpen(SessionParams: TJSONObject);
  public

  end;

var
  frmContactsMain: TfrmContactsMain;

implementation

{$R *.fmx}

procedure TfrmContactsMain.btnCancelClick(Sender: TObject);
begin
  FDQuery1.Cancel;
  TabControl1.ActiveTab := tiList;
end;

procedure TfrmContactsMain.btnDeleteClick(Sender: TObject);
begin
  FDQuery1.delete;
  TabControl1.ActiveTab := tiList;
end;

procedure TfrmContactsMain.btnEditClick(Sender: TObject);
begin
  edtName.Text := FDQuery1.FieldByName('name').AsString;
  edtFirstname.Text := FDQuery1.FieldByName('firstname').AsString;
  edtEmail.Text := FDQuery1.FieldByName('email').AsString;
  edtPhone.Text := FDQuery1.FieldByName('phone').AsString;
  FDQuery1.Edit;
  TabControl1.ActiveTab := tiRecord;
  edtName.SetFocus;
end;

procedure TfrmContactsMain.btnForceSynchroClick(Sender: TObject);
begin
  if assigned(FDBSync) and not(FDBSync.SyncState = TOlfTDSSyncState.Started)
  then
  begin
    btnForceSynchro.Enabled := false;
    tthread.CreateAnonymousThread(
      procedure
      begin
        FDBSync.Start;
        tthread.Queue(nil,
          procedure
          begin
            FDQuery1.Refresh;
            btnForceSynchro.Enabled := true;
          end);
      end).Start;
  end;
end;

procedure TfrmContactsMain.btnInsertClick(Sender: TObject);
begin
  edtName.Text := '';
  edtFirstname.Text := '';
  edtEmail.Text := '';
  edtPhone.Text := '';
  FDQuery1.Insert;
  TabControl1.ActiveTab := tiRecord;
  edtName.SetFocus;
end;

procedure TfrmContactsMain.btnPostClick(Sender: TObject);
begin
  FDQuery1.FieldByName('name').AsString := edtName.Text;
  FDQuery1.FieldByName('firstname').AsString := edtFirstname.Text;
  FDQuery1.FieldByName('email').AsString := edtEmail.Text;
  FDQuery1.FieldByName('phone').AsString := edtPhone.Text;
  FDQuery1.post;
  TabControl1.ActiveTab := tiList;
end;

procedure TfrmContactsMain.FDQuery1BeforeDelete(DataSet: TDataSet);
begin
  DataSet.Edit;
  DataSet.FieldByName('Sync_Delete').AsBoolean := true;
  DataSet.post;
  abort;
end;

procedure TfrmContactsMain.FDQuery1BeforePost(DataSet: TDataSet);
begin
  DataSet.FieldByName('Sync_Changed').AsBoolean := true;
  DataSet.FieldByName('Sync_ChangedDate').AsDateTime := now;
end;

procedure TfrmContactsMain.FormCreate(Sender: TObject);
var
  i: integer;
begin
  initTableDataSync;

  FDQuery1.Open;
  for i := 0 to FDQuery1.Fields.Count - 1 do
    if FDQuery1.Fields[i].DataType in [TFieldType.ftInteger,
      TFieldType.ftAutoInc, TFieldType.ftBoolean] then
      FDQuery1.Fields[i].DisplayWidth := 5
    else
      FDQuery1.Fields[i].DisplayWidth := 20;
  TabControl1.ActiveTab := tiList;
end;

procedure TfrmContactsMain.initTableDataSync;
var
  Tab: TOlfTDSTable;
begin
  FDBSync := TOlfTDSDatabase.Create(self);
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
  FDBSync.DefaultChangedFieldName := 'Sync_Changed';
  FDBSync.DefaultChangedDateTimeFieldName := 'Sync_ChangedDate';
  FDBSync.DefaultNoSeqFieldName := 'Sync_NoSeq';
  FDBSync.LocalConnectionDefName := dmContactsDB.getConnectionDefName;

  Tab := TOlfTDSTable.Create(self);
  Tab.AddKey(TOlfTDSField.Create('code', 'Sync_Code'));
  Tab.TableName := 'contacts';
  Tab.Database := FDBSync;
  Tab.SyncType := TOlfTDSSyncType.Mirroring;
  Tab.TableDeleteType := TOlfTDSTableDeleteType.Logical;
end;

procedure TfrmContactsMain.onSessionOpen(SessionParams: TJSONObject);
begin
  SessionParams.AddPair('user', 'MyUser');
  SessionParams.AddPair('password', 'MyPassword');
  SessionParams.AddPair('dbAlias', dmContactsDB.Name);
end;

initialization

{$IFDEF DEBUG}
  ReportMemoryLeaksOnShutdown := true;
{$ENDIF}

end.
