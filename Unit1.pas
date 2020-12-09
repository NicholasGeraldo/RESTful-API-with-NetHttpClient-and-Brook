(*
  By : NICHOLAS GERALDO

  RESTful API

  HTTP Method/Verbs :
   GET    - Mengambil Data
   POST   - Menambah  Data
   PUT    - Mengubah  Data
   DELETE - Menghapus Data

  Pada Aplikasi Client ini kita menggunakan NetHTTPClient
  (bisa juga pakai component RESTClient1, RESTRequest1, RESTResponse1)
  untuk melakukan CRUD ke WebService.

*)

unit Unit1;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs,
  System.Net.URLClient, System.Net.HttpClient, System.Net.HttpClientComponent,
  System.Rtti, FMX.Grid.Style, FMX.ScrollBox, FMX.Grid, FMX.StdCtrls,
  FMX.Controls.Presentation, FMX.Edit, FMX.Memo, REST.Types, REST.Client,
  Data.Bind.Components, Data.Bind.ObjectScope;

type
  TForm1 = class(TForm)
    NetHTTPClient: TNetHTTPClient;
    edtNama: TEdit;
    edtAlamat: TEdit;
    edtTelp: TEdit;
    edtID: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    btnTambah: TButton;
    btnUbah: TButton;
    btnHapus: TButton;
    StringGrid1: TStringGrid;
    edtCari: TEdit;
    Label4: TLabel;
    btnCari: TButton;
    StringColumn1: TStringColumn;
    StringColumn2: TStringColumn;
    StringColumn3: TStringColumn;
    StringColumn4: TStringColumn;
    RESTClient1: TRESTClient;
    RESTRequest1: TRESTRequest;
    RESTResponse1: TRESTResponse;
    procedure btnCariClick(Sender: TObject);
    procedure btnTambahClick(Sender: TObject);
    procedure btnUbahClick(Sender: TObject);
    procedure StringGrid1SelectCell(Sender: TObject; const ACol, ARow: Integer;
      var CanSelect: Boolean);
    procedure btnHapusClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.fmx}

Uses System.Json;

procedure TForm1.btnCariClick(Sender: TObject);
Var AResponse:string;
    JrTable:TJSONArray;
    JRec:TJSONObject;
    I:Integer;
begin
  /////////// METHOD GET ///////////////
   { METHOD POST untuk mengambil DATA }

   AResponse:=NetHTTPClient.Get('http://localhost:2020/customer/?search='+edtCari.Text).ContentAsString;
  ///////////////////////////////////////


  JrTable:= TJSONObject.ParseJSONValue(TEncoding.ASCII.GetBytes(AResponse),0) as TJSONArray;
  StringGrid1.RowCount:=JrTable.Size;
  for I := 0 to JrTable.Size-1 do
  begin
    JRec:=JrTable.Items[I] as TJSONObject;
    StringGrid1.Cells[0,I]:=JRec.GetValue('id').Value;
    StringGrid1.Cells[1,I]:=JRec.GetValue('nama').Value;
    StringGrid1.Cells[2,I]:=JRec.GetValue('alamat').Value;
    StringGrid1.Cells[3,I]:=JRec.GetValue('telp').Value;
  end;

end;

procedure TForm1.btnTambahClick(Sender: TObject);
Var AResponse:string;
    FormInput:TStringList;
begin
  FormInput := TStringList.Create;
  FormInput.Add('nama='+edtNama.Text);
  FormInput.Add('alamat='+edtAlamat.Text);
  FormInput.Add('telp='+edtTelp.Text);

  /////////// METHOD POST ///////////////
   { METHOD POST untuk menambah DATA }

   AResponse:=NetHTTPClient.Post('http://localhost:2020/customer',FormInput).ContentAsString;
  ///////////////////////////////////////

  btnCariClick(btnCari);
end;

procedure TForm1.btnUbahClick(Sender: TObject);
Var AResponse:string;
    FormInput:TStringList;
begin
  FormInput := TStringList.Create;
  FormInput.Add('id='+edtID.Text);
  FormInput.Add('nama='+edtNama.Text);
  FormInput.Add('alamat='+edtAlamat.Text);
  FormInput.Add('telp='+edtTelp.Text);

   /////////// METHOD PUT ///////////////
   { METHOD PUT untuk mengubah DATA }

    AResponse:=NetHTTPClient.Put('http://localhost:2020/customer',FormInput).ContentAsString;
  ///////////////////////////////////////

  btnCariClick(btnCari);
end;

procedure TForm1.btnHapusClick(Sender: TObject);
begin
  /////////// METHOD DELETE ///////////////
   { METHOD DELETE untuk menghapus DATA }

   NetHTTPClient.Delete('http://localhost:2020/customer/?id='+edtID.Text).ContentAsString;
  /////////////////////////////////////////


  btnCariClick(btnCari);
end;

procedure TForm1.StringGrid1SelectCell(Sender: TObject; const ACol,
  ARow: Integer; var CanSelect: Boolean);
Var AResponse:string;
    JrTable:TJSONArray;
    JRec:TJSONObject;
    I:Integer;
    ID:string;
begin
  ID:=StringGrid1.Cells[0,ARow];

  AResponse:=NetHTTPClient.Get('http://localhost:2020/customer/?id='+ID).ContentAsString;

  JrTable:= TJSONObject.ParseJSONValue(TEncoding.ASCII.GetBytes(AResponse),0) as TJSONArray;
  JRec:=JrTable.Items[0] as TJSONObject;
  edtID.Text:=JRec.GetValue('id').Value;
  edtNama.Text:=JRec.GetValue('nama').Value;
  edtAlamat.Text:=JRec.GetValue('alamat').Value;
  edtTelp.Text:=JRec.GetValue('telp').Value;

end;

end.
