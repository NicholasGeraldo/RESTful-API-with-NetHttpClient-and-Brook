program WebService;

uses
  System.StartUpCopy,
  FMX.Forms,
  uFrWebService in 'uFrWebService.pas' {FrWebService},
  Utility in 'Utility.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TFrWebService, FrWebService);
  Application.Run;
end.
