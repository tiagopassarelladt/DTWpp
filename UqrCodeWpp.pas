unit UqrCodeWpp;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.StdCtrls, System.IOUtils;

type
  TFrmqrCodeWpp = class(TForm)
    Image1: TImage;
    Button1: TButton;
    Button2: TButton;
    pnStatus: TPanel;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    FToken: string;
    FStatus: string;
    FSession: string;
    FSecretKey: string;
    FURLBase: string;
    FPorta: String;
    procedure SetSession(const Value: string);
    procedure SetStatus(const Value: string);
    procedure SetToken(const Value: string);
    procedure SetSecretKey(const Value: string);
    procedure SetPorta(const Value: String);
    procedure SetURLBase(const Value: string);
    { Private declarations }
  public
    property Status    : string read FStatus write SetStatus;
    property Session   : string read FSession write SetSession;
    property Token     : string read FToken write SetToken;
    property SecretKey : string read FSecretKey write SetSecretKey;
    property URLBase   : string read FURLBase write SetURLBase;
    property Porta     : String read FPorta write SetPorta;
  end;

var
  FrmqrCodeWpp: TFrmqrCodeWpp;

implementation

uses
  DTWpp;

{$R *.dfm}

procedure TFrmqrCodeWpp.Button1Click(Sender: TObject);
var
DTWppx : TDTWpp;
begin
     DTWppx               := TDTWpp.Create(nil);
     DTWppx.Session       := FSession;
     DTWppx.SecretKey     := FSecretKey;
     DTWppx.URLBase       := FURLBase;
     DTWppx.Porta         := FPorta;
     DTWppx.StartSession;

     pnStatus.Caption := DTWppx.RetornoSession.status;

     if DTWppx.RetornoSession.TemQrcode  then
         Image1.Picture.LoadFromFile( TPath.GetTempPath + FSession + '.png'  );

     FreeAndNil( DTWppx );
end;

procedure TFrmqrCodeWpp.Button2Click(Sender: TObject);
var
DTWppx : TDTWpp;
begin
     DTWppx               := TDTWpp.Create(nil);
     DTWppx.Session       := FSession;
     DTWppx.SecretKey     := FSecretKey;
     DTWppx.URLBase       := FURLBase;
     DTWppx.Porta         := FPorta;
     DTWppx.StatuSsession;

     pnStatus.Caption := DTWppx.RetornoSession.status;

     if DTWppx.RetornoSession.TemQrcode  then
         Image1.Picture.LoadFromFile( TPath.GetTempPath + FSession + '.png' );

     FreeAndNil( DTWppx );

     if pnStatus.Caption = 'CONNECTED' then
      CLOSE;
end;

procedure TFrmqrCodeWpp.FormClose(Sender: TObject; var Action: TCloseAction);
begin
    Action       := caFree;
    FrmqrCodeWpp := nil;
end;

procedure TFrmqrCodeWpp.FormShow(Sender: TObject);
begin
     Button1Click(Sender);
end;

procedure TFrmqrCodeWpp.SetPorta(const Value: String);
begin
  FPorta := Value;
end;

procedure TFrmqrCodeWpp.SetSecretKey(const Value: string);
begin
  FSecretKey := Value;
end;

procedure TFrmqrCodeWpp.SetSession(const Value: string);
begin
  FSession := Value;
end;

procedure TFrmqrCodeWpp.SetStatus(const Value: string);
begin
  FStatus := Value;
end;

procedure TFrmqrCodeWpp.SetToken(const Value: string);
begin
  FToken := Value;
end;

procedure TFrmqrCodeWpp.SetURLBase(const Value: string);
begin
  FURLBase := Value;
end;

end.
