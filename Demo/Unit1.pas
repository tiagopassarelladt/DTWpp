unit Unit1;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, DTWpp, Vcl.ExtCtrls,TypInfo,System.Rtti,UEmoticons, System.IOUtils;

type
  TForm1 = class(TForm)
    msg: TMemo;
    Button1: TButton;
    edtSession: TEdit;
    edtSecretKey: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    edtToken: TEdit;
    Label3: TLabel;
    Button2: TButton;
    Image1: TImage;
    Button3: TButton;
    Button4: TButton;
    Button5: TButton;
    edtTelefone: TEdit;
    edtMensagem: TEdit;
    Button6: TButton;
    OpenDialog1: TOpenDialog;
    Button7: TButton;
    Button8: TButton;
    Button9: TButton;
    Button10: TButton;
    Button11: TButton;
    DTWpp1: TDTWpp;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure Button5Click(Sender: TObject);
    procedure Button6Click(Sender: TObject);
    procedure Button7Click(Sender: TObject);
    procedure Button8Click(Sender: TObject);
    procedure Button9Click(Sender: TObject);
    procedure Button10Click(Sender: TObject);
    procedure Button11Click(Sender: TObject);
  private
    procedure configuraComponente;
  public

  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

{ TForm1 }

procedure TForm1.Button10Click(Sender: TObject);
begin
         configuraComponente;
         DTWpp1.SendButtons1Opcao(edtTelefone.Text,
                            'ol� essa � uma mensagem de sua fatura que est� disponivel para pagamento',
                            '5535984240000',
                            'Falar com atendente',
                            'https://www.passarellasistemas.com.br',
                            'Acesse nosso site',
                            'Financeiro',
                            'Obrigado pela preferencia',
                            'Recebido');
         edtToken.Text    := DTWpp1.RetornoAuth.token;

         msg.Lines.Clear;
         msg.Lines.Add('mensagem: ' + DTWpp1.Retorno.mensagem );
end;

procedure TForm1.Button11Click(Sender: TObject);
begin
         configuraComponente;
         DTWpp1.SendButtons2Opcoes(edtTelefone.Text,
                            'ol� essa � uma mensagem de sua fatura que est� disponivel para pagamento',
                            '5535984240000',
                            'Falar com atendente ',
                            'https://www.passarellasistemas.com.br',
                            'Acesse nosso site',
                            'Financeiro',
                            'Obrigado pela preferencia',
                            'Recebido',
                            'Nao recebi');
         edtToken.Text    := DTWpp1.RetornoAuth.token;

         msg.Lines.Clear;
         msg.Lines.Add('mensagem: ' + DTWpp1.Retorno.mensagem  );
end;

procedure TForm1.Button1Click(Sender: TObject);
begin
     configuraComponente;
     DTWpp1.generatetoken;
     if DTWpp1.RetornoAuth.token = '' then
     begin
        if edtToken.Text <> '' then
           edtToken.Text    := DTWpp1.RetornoAuth.token;
     end else begin
        edtToken.Text := DTWpp1.RetornoAuth.token;
     end;

     msg.Lines.Clear;
     msg.Lines.Add( DTWpp1.RetornoAuth.mensagem );
end;

procedure TForm1.Button2Click(Sender: TObject);
begin
     configuraComponente;
     DTWpp1.StartSession;
     edtToken.Text    := DTWpp1.RetornoAuth.token;

     msg.Lines.Clear;
     msg.Lines.Add('status: ' + DTWpp1.RetornoSession.status );
     msg.Lines.Add('qrcode: ' + DTWpp1.RetornoSession.qrcode );

     if DTWpp1.RetornoSession.TemQrcode  then
         Image1.Picture.LoadFromFile( TPath.GetTempPath + DTWpp1.Session + '.png' );
end;

procedure TForm1.Button3Click(Sender: TObject);
begin
     configuraComponente;
     DTWpp1.statussession;
     edtToken.Text    := DTWpp1.RetornoAuth.token;

     msg.Lines.Clear;
     msg.Lines.Add('status: ' + DTWpp1.RetornoSession.status );
     msg.Lines.Add('qrcode: ' + DTWpp1.RetornoSession.qrcode );

     if DTWpp1.RetornoSession.TemQrcode  then
         Image1.Picture.LoadFromFile( TPath.GetTempPath + DTWpp1.Session + '.png' );
end;

procedure TForm1.Button4Click(Sender: TObject);
begin
     configuraComponente;
     DTWpp1.LogoutSession;
     edtToken.Text    := DTWpp1.RetornoAuth.token;

     msg.Lines.Clear;
     msg.Lines.Add('status: ' + DTWpp1.RetornoSession.status );
end;

procedure TForm1.Button5Click(Sender: TObject);
begin
     configuraComponente;
     DTWpp1.sendmessage(edtTelefone.Text, edtMensagem.Text + DTWpp1.Emoticons.SorridenteLingua);
     edtToken.Text    := DTWpp1.RetornoAuth.token;

     msg.Lines.Clear;
     msg.Lines.Add('mensagem: ' + DTWpp1.Retorno.mensagem );
end;

procedure TForm1.Button6Click(Sender: TObject);
begin
    if OpenDialog1.Execute then
    begin
         configuraComponente;
         DTWpp1.SendFile(edtTelefone.Text, ExtractFileName(OpenDialog1.FileName), edtMensagem.Text, OpenDialog1.FileName);
         edtToken.Text    := DTWpp1.RetornoAuth.token;

         msg.Lines.Clear;
         msg.Lines.Add('mensagem: ' + DTWpp1.Retorno.mensagem );
    end;
end;

procedure TForm1.Button7Click(Sender: TObject);
begin
    if OpenDialog1.Execute then
    begin
         configuraComponente;
         DTWpp1.Sendimage(edtTelefone.Text, ExtractFileName(OpenDialog1.FileName), edtMensagem.Text, OpenDialog1.FileName);
         edtToken.Text    := DTWpp1.RetornoAuth.token;

         msg.Lines.Clear;
         msg.Lines.Add('mensagem: ' + DTWpp1.Retorno.mensagem );
    end;
end;

procedure TForm1.Button8Click(Sender: TObject);
var
  RttiContext: TRttiContext;
  RttiType: TRttiType;
  RttiField: TRttiField;
begin
  RttiContext := TRttiContext.Create;
  try
    RttiType := RttiContext.GetType(TypeInfo(TWPPEmitions));
    for RttiField in RttiType.GetFields do
    begin
      Writeln(RttiField.Name + ': ' + RttiField.GetValue(nil).AsString);
    end;
  finally
    RttiContext.Free;
  end;

end;

procedure TForm1.Button9Click(Sender: TObject);
begin
         configuraComponente;
         DTWpp1.SendButtons3Opcoes(edtTelefone.Text,
                            'ol� essa � uma mensagem de sua fatura que est� disponivel para pagamento',
                            '5535984240000',
                            'Falar com atendente ',
                            'https://www.passarellasistemas.com.br',
                            'Acesse nosso site',
                            'Financeiro',
                            'Obrigado pela preferencia',
                            'Recebido',
                            'Nao recebi',
                            'Preciso de ajuda');
         edtToken.Text    := DTWpp1.RetornoAuth.token;

         msg.Lines.Clear;
         msg.Lines.Add('mensagem: ' + DTWpp1.Retorno.mensagem );
end;

procedure TForm1.configuraComponente;
begin
     DTWpp1.Session       := edtSession.Text;
     DTWpp1.SecretKey     := edtSecretKey.Text;
     DTWpp1.URLBase       := 'http://www.dtloja.com.br';
     DTWpp1.Porta         := '30000';
end;

end.
