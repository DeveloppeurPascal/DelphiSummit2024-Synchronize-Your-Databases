program DS2024SimpleNotes;

uses
  System.StartUpCopy,
  FMX.Forms,
  fMain in 'fMain.pas' {frmMain},
  SimpleNotes.DB in 'SimpleNotes.DB.pas' {dmSimpleNotesDB: TDataModule},
  Olf.RTL.GenRandomID in '..\..\lib-externes\librairies\src\Olf.RTL.GenRandomID.pas',
  Olf.TableDataSync in '..\..\lib-externes\PV-TableDataSync-Delphi\src\Olf.TableDataSync.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TdmSimpleNotesDB, dmSimpleNotesDB);
  Application.CreateForm(TfrmMain, frmMain);
  Application.Run;
end.
