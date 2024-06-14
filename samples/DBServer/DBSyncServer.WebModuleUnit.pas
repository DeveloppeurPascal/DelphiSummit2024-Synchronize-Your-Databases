unit DBSyncServer.WebModuleUnit;

interface

uses
  System.SysUtils,
  System.Classes,
  Web.HTTPApp,
  Olf.TableDataSync.WebModuleUnit;

type
  TServerWebModule = class(TOlfTDSWebModule)
  private

  public
    function LoginCheck(Request: TWebRequest): Boolean; override;
    function GetConnectionDefName(Request: TWebRequest): string; override;
  end;

var
  ServerWebModule: TServerWebModule;

implementation

{%CLASSGROUP 'System.Classes.TPersistent'}

uses
  Contacts.DB,
  SimpleNotes.DB;

{$R *.dfm}
{ TServerWebModule }

function TServerWebModule.GetConnectionDefName(Request: TWebRequest): string;
var
  dmName: string;
begin
  if not assigned(dmContactsDB) then
    dmContactsDB := tdmContactsDB.Create(self);

  if not assigned(dmSimpleNotesDB) then
    dmSimpleNotesDB := TdmSimpleNotesDB.Create(self);

  dmName := getPostValueAsString(Request, 'dbAlias').Trim;
  if dmName = dmContactsDB.Name then
    result := dmContactsDB.GetConnectionDefName
  else if dmName = dmSimpleNotesDB.Name then
    result := dmSimpleNotesDB.GetConnectionDefName
  else
    raise Exception.Create('Unknow database !');
end;

function TServerWebModule.LoginCheck(Request: TWebRequest): Boolean;
begin
  result := (getPostValueAsString(Request, 'user') = 'MyUser') and
    (getPostValueAsString(Request, 'password') = 'MyPassword');
end;

end.
