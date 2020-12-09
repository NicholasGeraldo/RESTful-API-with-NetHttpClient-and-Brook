(*
  By : NICHOLAS GERALDO

  RESTful API

  HTTP Method/Verbs :
   GET    - Mengambil Data
   POST   - Menambah  Data
   PUT    - Mengubah  Data
   DELETE - Menghapus Data


  ini merupakan Aplikasi Webservice sederhana untuk penerapan RESTful API
  di PASCAL - DELPHI menggunakan brookframework (bisa di buat menggunakan Lazarus juga
  karena brookframework support Lazarus).

  Karena hanya Demo database yang di pakai pakai aplikasi ini adalah SQLite (JUST DEMO),
  Kalian bisa terapkan menggunakan Database MySQL, Firebird atau yang lainnya.

*)

unit uFrWebService;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, BrookURLRouter,
  BrookHandledClasses, BrookHTTPServer, BrookHTTPRequest, BrookHTTPResponse,
  System.Actions, FMX.ActnList, FMX.StdCtrls, FMX.Edit, FMX.EditBox,
  Utility, FMX.NumberBox, FMX.Controls.Presentation, FireDAC.Stan.Intf,
  FireDAC.Stan.Option, FireDAC.Stan.Error, FireDAC.UI.Intf, FireDAC.Phys.Intf,
  FireDAC.Stan.Def, FireDAC.Stan.Pool, FireDAC.Stan.Async, FireDAC.Phys,
  FireDAC.Phys.SQLite, FireDAC.Phys.SQLiteDef, FireDAC.Stan.ExprFuncs,
  FireDAC.FMXUI.Wait, FireDAC.Stan.Param, FireDAC.DatS, FireDAC.DApt.Intf,
  FireDAC.DApt, Data.DB, FireDAC.Comp.DataSet, FireDAC.Comp.Client, System.Json,
  FireDAC.Comp.UI;

type
  TFrWebService = class(TForm)
    BrookHTTPServer1: TBrookHTTPServer;
    BrookURLRouter1: TBrookURLRouter;
    pnTop: TPanel;
    lbPort: TLabel;
    edPort: TNumberBox;
    btStart: TButton;
    btStop: TButton;
    alMain: TActionList;
    acStart: TAction;
    acStop: TAction;
    lbLink: TLabel;
    FDConnection: TFDConnection;
    FDQuery: TFDQuery;
    FDPhysSQLiteDriverLink1: TFDPhysSQLiteDriverLink;
    FDGUIxWaitCursor1: TFDGUIxWaitCursor;
    procedure acStartExecute(Sender: TObject);
    procedure acStopExecute(Sender: TObject);
    procedure BrookHTTPServer1Stop(Sender: TObject);
    procedure lbLinkClick(Sender: TObject);
    procedure BrookHTTPServer1Request(ASender: TObject;
      ARequest: TBrookHTTPRequest; AResponse: TBrookHTTPResponse);
    procedure BrookURLRouter1Routes0Request(ASender: TObject;
      ARoute: TBrookURLRoute; ARequest: TBrookHTTPRequest;
      AResponse: TBrookHTTPResponse);
    procedure BrookURLRouter1Routes1Request(ASender: TObject;
      ARoute: TBrookURLRoute; ARequest: TBrookHTTPRequest;
      AResponse: TBrookHTTPResponse);
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
    procedure Konek_To_Database;
    function  DataPelanggan(Cari:string):string;
    function  DetailPelanggan(id:string):string;
  public
    { Public declarations }
    procedure UpdateControls; inline;
  end;

var
  FrWebService: TFrWebService;

implementation

{$R *.fmx}

procedure TFrWebService.acStartExecute(Sender: TObject);
begin
  Konek_To_Database;
  UpdateControls;
  BrookURLRouter1.Open;
  BrookHTTPServer1.Open;
end;

procedure TFrWebService.acStopExecute(Sender: TObject);
begin
  BrookHTTPServer1.Close;
end;

procedure TFrWebService.BrookHTTPServer1Request(ASender: TObject;
  ARequest: TBrookHTTPRequest; AResponse: TBrookHTTPResponse);
begin
  BrookURLRouter1.Route(ASender, ARequest, AResponse);
end;

procedure TFrWebService.BrookHTTPServer1Stop(Sender: TObject);
begin
  UpdateControls;
end;

procedure TFrWebService.BrookURLRouter1Routes0Request(ASender: TObject;
  ARoute: TBrookURLRoute; ARequest: TBrookHTTPRequest;
  AResponse: TBrookHTTPResponse);
begin
  AResponse.Send(
    '<html><head><title>Home page</title></head><body>Home page</body></html>',
    'text/html; charset=utf-8', 200);
end;

procedure TFrWebService.BrookURLRouter1Routes1Request(ASender: TObject;
  ARoute: TBrookURLRoute; ARequest: TBrookHTTPRequest;
  AResponse: TBrookHTTPResponse);
var JsonData : string;
begin

  if ARequest.Method='GET' then
  begin
    if ARequest.Params.Values['id']='' then
       JsonData:=DataPelanggan(ARequest.Params.Values['search']) else
       JsonData:=DetailPelanggan(ARequest.Params.Values['id']);

    AResponse.Send(JsonData,'application/json', 200);
  end;

  if ARequest.Method='POST' then
  begin
    try
      FDQuery.SQL.Clear;
      FDQuery.SQL.Text:='insert into pelanggan (nama,alamat,telp) values ('+
      QuotedStr(ARequest.Fields.Values['nama'])+','+
      QuotedStr(ARequest.Fields.Values['alamat'])+','+
      QuotedStr(ARequest.Fields.Values['telp'])+')';
      FDQuery.ExecSQL;

      AResponse.Send('{"status":"sukses"}','application/json', 200);
    except
      AResponse.Send('{"status":"gagal"}','application/json', 200);
    end;
  end;


  if ARequest.Method='PUT' then
  begin
    try
      FDQuery.SQL.Clear;
      FDQuery.SQL.Text:='update pelanggan set '+
      'nama='+QuotedStr(ARequest.Fields.Values['nama'])+','+
      'alamat='+QuotedStr(ARequest.Fields.Values['alamat'])+','+
      'telp='+QuotedStr(ARequest.Fields.Values['telp'])+' '+
      'where id='+ARequest.Fields.Values['id']+'';
      FDQuery.ExecSQL;

      AResponse.Send('{"status":"sukses"}','application/json', 200);
    except
      AResponse.Send('{"status":"gagal"}','application/json', 200);
    end;
  end;


  if ARequest.Method='DELETE' then
  begin
    try
      FDQuery.SQL.Clear;
      FDQuery.SQL.Text:='delete from pelanggan '+
      'where id='+ARequest.Params.Values['id']+'';
      FDQuery.ExecSQL;

      AResponse.Send('{"status":"sukses"}','application/json', 200);
    except
      AResponse.Send('{"status":"gagal"}','application/json', 200);
    end;
  end;

end;

function TFrWebService.DataPelanggan(Cari: string): string;
Var JsArray : TJSONArray;
    JsObject: TJSONOBject;
    I:Integer;
begin
  FDQuery.Open('select * from pelanggan '+
                    'where nama like '+QuotedStr('%'+Cari+'%'));
  FDQuery.Open;
  JsArray := TJSONArray.Create;
  for I := 0 to FDQuery.RecordCount - 1 do
  begin
     JsObject := TJSONOBject.Create;
     JsObject.AddPair('id', FDQuery.FieldByName('id').AsString);
     JsObject.AddPair('nama', FDQuery.FieldByName('nama').AsString);
     JsObject.AddPair('alamat', FDQuery.FieldByName('alamat').AsString);
     JsObject.AddPair('telp', FDQuery.FieldByName('telp').AsString);
    JsArray.AddElement(JsObject);
    FDQuery.Next;
  end;

  Result:=JsArray.ToString;

end;

function TFrWebService.DetailPelanggan(id: string): string;
Var JsArray : TJSONArray;
    JsObject: TJSONOBject;
    I:Integer;
begin
  FDQuery.Open('select * from pelanggan '+
                    'where id='+QuotedStr(id));
  FDQuery.Open;
  JsArray := TJSONArray.Create;
  for I := 0 to FDQuery.RecordCount - 1 do
  begin
     JsObject := TJSONOBject.Create;
     JsObject.AddPair('id', FDQuery.FieldByName('id').AsString);
     JsObject.AddPair('nama', FDQuery.FieldByName('nama').AsString);
     JsObject.AddPair('alamat', FDQuery.FieldByName('alamat').AsString);
     JsObject.AddPair('telp', FDQuery.FieldByName('telp').AsString);
    JsArray.AddElement(JsObject);
    FDQuery.Next;
  end;

  Result:=JsArray.ToString;

end;

procedure TFrWebService.FormShow(Sender: TObject);
begin
  acStart.Execute;
end;

procedure TFrWebService.Konek_To_Database;
begin
  try
    FDConnection.Params.Add('database='+ExtractFilePath(ParamStr(0))+'data.db');
    FDConnection.Connected:=true;
  except
    ShowMessage('Koneksi Gagal');
  end;
end;

procedure TFrWebService.lbLinkClick(Sender: TObject);
begin
  Utility.OpenURL(lbLink.Text);
end;

procedure TFrWebService.UpdateControls;
begin
  if Application.Terminated then  Exit;
  if BrookHTTPServer1.Active then
    edPort.Value := BrookHTTPServer1.Port else BrookHTTPServer1.Port := edPort.Text.ToInteger;

  lbLink.Text := Concat('http://localhost:', edPort.Value.ToString);
  acStart.Enabled := not BrookHTTPServer1.Active;
  acStop.Enabled := not acStart.Enabled;
  edPort.Enabled := acStart.Enabled;
  lbLink.Enabled := not acStart.Enabled;
end;

end.
