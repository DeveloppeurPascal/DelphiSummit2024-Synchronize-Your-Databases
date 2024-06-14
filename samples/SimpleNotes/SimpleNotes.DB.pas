unit SimpleNotes.DB;

interface

uses
  System.SysUtils,
  System.Classes,
  FireDAC.Stan.Intf,
  FireDAC.Stan.Option,
  FireDAC.Stan.Error,
  FireDAC.UI.Intf,
  FireDAC.Phys.Intf,
  FireDAC.Stan.Def,
  FireDAC.Stan.Pool,
  FireDAC.Stan.Async,
  FireDAC.Phys,
  FireDAC.ConsoleUI.Wait,
  FireDAC.Comp.ScriptCommands,
  FireDAC.Stan.Util,
  FireDAC.Comp.Script,
  Data.DB,
  FireDAC.Comp.Client,
  FireDAC.Stan.ExprFuncs,
  FireDAC.Phys.SQLiteWrapper.Stat,
  FireDAC.Phys.SQLiteDef,
  FireDAC.Comp.UI,
  FireDAC.Phys.SQLite;

type
  TdmSimpleNotesDB = class(TDataModule)
    FDConnection1: TFDConnection;
    FDScript1: TFDScript;
    FDPhysSQLiteDriverLink1: TFDPhysSQLiteDriverLink;
    FDGUIxWaitCursor1: TFDGUIxWaitCursor;
    procedure FDConnection1AfterConnect(Sender: TObject);
    procedure FDConnection1BeforeConnect(Sender: TObject);
    procedure DataModuleCreate(Sender: TObject);
  private
  protected
    FConnectionDefName: string;
    function getDBFileName: string;
    function getDBVersionFileName: string;
  public
    function getConnectionDefName: string;
  end;

var
  dmSimpleNotesDB: TdmSimpleNotesDB;

implementation

{%CLASSGROUP 'System.Classes.TPersistent'}
{$R *.dfm}

uses
  System.IOUtils,
  Olf.RTL.GenRandomID;

procedure TdmSimpleNotesDB.DataModuleCreate(Sender: TObject);
begin
  FConnectionDefName := '';
  FDConnection1.Open;
end;

procedure TdmSimpleNotesDB.FDConnection1AfterConnect(Sender: TObject);
var
  i: integer;
  dbv: integer;
  dbvFileName: string;
begin
  dbvFileName := getDBVersionFileName;

  if tfile.Exists(dbvFileName) then
    dbv := tfile.ReadAllText(dbvFileName).ToInteger
  else
    dbv := 0;

  for i := dbv to FDScript1.SQLScripts.Count - 1 do
  begin
    FDScript1.ExecuteScript(FDScript1.SQLScripts[i].SQL);
    tfile.WriteAllText(dbvFileName, (i + 1).ToString);
  end;
end;

procedure TdmSimpleNotesDB.FDConnection1BeforeConnect(Sender: TObject);
var
  cdn: string;
begin
  cdn := getConnectionDefName;
  if FDManager.IsConnectionDef(cdn) then
  begin
    FDConnection1.Params.Clear;
    FDConnection1.ConnectionDefName := cdn;
  end
  else
  begin
    FDConnection1.Params.Clear;
    FDConnection1.Params.DriverID := 'SQLite';
    FDConnection1.Params.Database := getDBFileName;
    FDManager.AddConnectionDef(cdn, 'SQLite', FDConnection1.Params);
  end;
end;

function TdmSimpleNotesDB.getConnectionDefName: string;
begin
  if FConnectionDefName.IsEmpty then
    FConnectionDefName := TOlfRandomIDGenerator.getIDBase62(50);
  result := FConnectionDefName;
end;

function TdmSimpleNotesDB.getDBFileName: string;
var
  Folder, FileName: string;
begin
{$IFDEF DEBUG}
  Folder := tpath.combine(tpath.GetDocumentsPath, 'DelphiSummit2024-DEBUG');
  FileName := 'SimpleNotes-DEBUG';
{$ELSE}
{$IFDEF IOS}
  Folder := tpath.combine(tpath.GetDocumentsPath, 'DelphiSummit2024');
{$ELSE}
  Folder := tpath.combine(tpath.GetHomePath, 'DelphiSummit2024');
{$ENDIF}
  FileName := 'SimpleNotes';
{$ENDIF}
{$IF Defined(CONSOLE)}
  Folder := tpath.combine(Folder, 'Server');
{$ELSEIF Defined(WIN32)}
  Folder := tpath.combine(Folder, 'Win32');
{$ELSEIF Defined (WIN64)}
  Folder := tpath.combine(Folder, 'Win64');
{$ENDIF}
  if not tdirectory.Exists(Folder) then
    tdirectory.CreateDirectory(Folder);
  result := tpath.combine(Folder, FileName + '.db');
end;

function TdmSimpleNotesDB.getDBVersionFileName: string;
begin
  result := getDBFileName + 'v';
end;

end.
