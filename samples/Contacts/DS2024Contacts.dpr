program DS2024Contacts;

uses
  System.StartUpCopy,
  FMX.Forms,
  Contacts.Main in 'Contacts.Main.pas' {frmContactsMain},
  Contacts.DB in 'Contacts.DB.pas' {dmContactsDB: TDataModule},
  Olf.RTL.GenRandomID in '..\..\lib-externes\librairies\src\Olf.RTL.GenRandomID.pas',
  Olf.TableDataSync in '..\..\lib-externes\PV-TableDataSync-Delphi\src\Olf.TableDataSync.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TdmContactsDB, dmContactsDB);
  Application.CreateForm(TfrmContactsMain, frmContactsMain);
  Application.Run;
end.
