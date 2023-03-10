﻿unit DTWpp;

interface

uses
  System.SysUtils, System.Classes, Vcl.ExtCtrls,
  System.Net.URLClient,
  System.Net.HttpClient, System.netEncoding,
  System.Net.HttpClientComponent,json,Vcl.Graphics , Soap.EncdDecd,Vcl.Imaging.pngimage, UEmoticons;

type TRetAuth = record
     code     : integer;
     mensagem : string;
     status   : string;
     session  : string;
     token    : string;
end;

type TSessionQR = record
  status: String;
  qrcode: string;
  version: String;
  session: String;
  TemQrcode:boolean;
end;

type TRetornoPadrao = record
     Mensagem : string;
end;

type
  TDTWpp = class(TComponent)
  private
    FSecretKey: string;
    FSession: string;
    FCaminhoQrCode: string;
    FURLBase: string;
    FPorta: string;
    FEmoticons: TWPPEmitions;
    procedure SetSecretKey(const Value: string);
    procedure SetSession(const Value: string);
    procedure SetCaminhoQrCode(const Value: string);
    function BitmapFromBase64(const base64: string): Boolean;
    function FileToBase64(Arquivo : String): String;
    function StreamToBase64(STream: TMemoryStream): String;
    procedure SetPorta(const Value: string);
    procedure SetURLBase(const Value: string);
    procedure SetEmoticons(const Value: TWPPEmitions);

  protected

  public
       RetornoAuth:TRetAuth;
       RetornoSession:TSessionQR;
       Retorno:TRetornoPadrao;
       function GenerateToken:boolean;
       function StartSession:boolean;
       function StatuSsession:boolean;
       function LogoutSession:boolean;
       function SendMessage(Telefone:string;Mensagem:string): Boolean;
       function SendFile(Telefone:string;FileName:string;Mensagem:string;CaminhoDoArquivo:string): Boolean;
       function SendImage(Telefone:string;FileName:string;Mensagem:string;CaminhoDoArquivo:string): Boolean;
       function SendButtons1Opcao(Telefone,CorpodaMensagem,TelefoneLigar,TextoBotaoTelefone,LinkRedirecionamento,TextodoLink,TituloMensagem, RodapeDaMensagem, Opcao1: string): Boolean;
       function SendButtons2Opcoes(Telefone,CorpodaMensagem,TelefoneLigar,TextoBotaoTelefone,LinkRedirecionamento,TextodoLink,TituloMensagem, RodapeDaMensagem, Opcao1,Opcao2: string): Boolean;
       function SendButtons3Opcoes(Telefone,CorpodaMensagem,TelefoneLigar,TextoBotaoTelefone,LinkRedirecionamento,TextodoLink,TituloMensagem, RodapeDaMensagem, Opcao1,Opcao2,Opcao3: string): Boolean;

  published
    property Session       : string       read FSession       write SetSession;
    property SecretKey     : string       read FSecretKey     write SetSecretKey;
    property CaminhoQrCode : string       read FCaminhoQrCode write SetCaminhoQrCode;
    property URLBase       : string       read FURLBase       write SetURLBase;
    property Porta         : string       read FPorta         write SetPorta;
    property Emoticons     : TWPPEmitions read FEmoticons     write SetEmoticons;
  end;

  //const
  //FURLBase:FPorta  = 'http://www.dtloja.com.br:30000/api';

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('DT Inovacao', [TDTWpp]);
end;

{ TDTWpp }

function TDTWpp.StreamToBase64(STream: TMemoryStream): String;
Var Base64 : tBase64Encoding;
begin
  Try
    Stream.Position := 0; {ANDROID 64 e 32 Bits}
//    Stream.Seek(0, 0); {ANDROID 32 Bits}
    Base64 := TBase64Encoding.Create;
    Result := Base64.EncodeBytesToString(sTream.Memory, sTream.Size);
  Finally
    Base64.Free;
    Base64:=nil;
  End;
end;

function TDTWpp.FileToBase64(Arquivo : String): String;
Var sTream : tMemoryStream;
begin
  if (Trim(Arquivo) <> '') then
  begin
     sTream := TMemoryStream.Create;
     Try
       sTream.LoadFromFile(Arquivo);
       result := StreamToBase64(sTream);
     Finally
       Stream.Free;
       Stream:=nil;
     End;
  end else
     result := '';
end;

function TDTWpp.BitmapFromBase64(const base64: string): Boolean;
var
 s : TMemoryStream;
 png : TPngImage;
 bb : TBytes;
begin
  try
      try
        s := TMemoryStream.Create;
        bb := decodebase64( base64 );
        if Length(bb)>0 then
        begin
          s.WriteData(bb,Length(bb));
          s.position:=0;
          png:=TPngImage.Create;
          png.LoadFromStream(s);
          if FileExists( FCaminhoQrCode + FSession + '.png' ) then
             DeleteFile( FCaminhoQrCode + FSession + '.png' );

          png.SaveToFile( FCaminhoQrCode + FSession + '.png' );
          FCaminhoQrCode := FCaminhoQrCode + FSession + '.png';
          Result := True;
          png.Destroy;
        end;
        s.free;
      except
        Result := False;
      end;
  finally

  end;
end;

function TDTWpp.generatetoken: boolean;
var
  HttpClient  : THttpClient;
  Response    : IHttpResponse;
  RequestBody : TStringStream;
  xURL        : string;
  obj         : TJSONObject;
begin
    try
      HttpClient             := THttpClient.Create;
      HttpClient.ContentType := 'application/json';
      HttpClient.Accept      := '/';
      RequestBody            := TStringStream.Create;

      try
        Response := HttpClient.Post( FURLBase+':'+FPorta  + '/api/'+ FSession +'/' + FSecretKey + '/generate-token',
                      RequestBody, nil);

        if Response.StatusCode in[ 200, 201 ] then
        begin
           result               := true;
           RetornoAuth.code     := Response.StatusCode;
           RetornoAuth.Mensagem := Response.ContentAsString;

           obj := TJSONObject.ParseJSONValue(TEncoding.UTF8.GetBytes( Response.ContentAsString ), 0) as TJSONObject;

           RetornoAuth.status  := obj.GetValue('status').Value;
           RetornoAuth.session := obj.GetValue('session').Value;
           RetornoAuth.token   := obj.GetValue('token').Value;

        end else begin
           Result := False;
           raise Exception.Create(Response.StatusCode.ToString + ' ' + Response.StatusText + ' ' + Response.ContentAsString);
        end;

      except
        on E:Exception do
        begin
           Result := false;
           raise Exception.Create(E.Message);
        end;
      end;

    finally
      if Assigned(RequestBody) then
        FreeAndNil(RequestBody);
      if Assigned(HttpClient) then
        FreeAndNil(HttpClient);
    end;

end;

function TDTWpp.LogoutSession: boolean;
var
  HttpClient  : THttpClient;
  Response    : IHttpResponse;
  RequestBody : TStringStream;
  xURL        : string;
  obj         : TJSONObject;
begin
    try
      if RetornoAuth.token = '' then
          generatetoken;

      HttpClient             := THttpClient.Create;
      HttpClient.ContentType := 'application/json';
      HttpClient.Accept      := '/';
      RequestBody := TStringStream.Create;

      try
        Response := HttpClient.Post( FURLBase+':'+FPorta  + '/api/'+ FSession +'/logout-session',
                                     RequestBody,nil,
                                     TNetHeaders.Create(TNameValuePair.Create('Authorization', 'Bearer ' + RetornoAuth.token))
                                     );

        if Response.StatusCode in[ 200, 201 ] then
        begin
           result                  := True;
           obj := TJSONObject.ParseJSONValue(TEncoding.UTF8.GetBytes( Response.ContentAsString ), 0) as TJSONObject;

           RetornoSession.status   := obj.GetValue('status').Value;
        end else begin
           Result := False;
           raise Exception.Create(Response.StatusCode.ToString + ' ' + Response.StatusText + ' ' + Response.ContentAsString);
        end;

      except
        on E:Exception do
        begin
           Result := false;
           raise Exception.Create(E.Message);
        end;
      end;

    finally
      if Assigned(RequestBody) then
        FreeAndNil(RequestBody);
      if Assigned(HttpClient) then
        FreeAndNil(HttpClient);
    end;

end;

function TDTWpp.SendButtons1Opcao(Telefone, CorpodaMensagem, TelefoneLigar,
  TextoBotaoTelefone, LinkRedirecionamento, TextodoLink, TituloMensagem,
  RodapeDaMensagem, Opcao1: string): Boolean;
const
  REQUEST_BODY =
  ' { ' +
  ' "phone": "%s", ' + // telefone
  ' "message": "%s", ' +  // corpo da mensagem
  ' "options": { ' +
  ' "useTemplateButtons": "true", ' +
  ' "buttons": [ ' +
  ' { ' +
  ' "id": "1", ' +
  ' "text": "%s" ' + // Opcao 1
  ' }, ' +
  ' { ' +
  ' "id": "2", ' +
  ' "phoneNumber": "%s", ' + // telefone do botao de ligar 55dddxxxxxxxx
  ' "text": "%s" ' + // texto do botao de ligar
  ' }, ' +
  ' { ' +
  ' "id": "3", ' +
  ' "url": "%s", ' + // link de redirecionamento
  ' "text": "%s" ' + // texto referente ao link
  ' } ' +
  ' ], ' +
  ' "title": "%s", ' +  // titulo da mensagem
  ' "footer": "%s" ' + // rodape da mensagem
  ' } ' +
  ' } ';

var
  HttpClient  : THttpClient;
  Response    : IHttpResponse;
  RequestBody : TStringStream;
  xURL        : string;
  obj         : TJSONObject;
begin
    try
      if RetornoAuth.token = '' then
          generatetoken;

      HttpClient             := THttpClient.Create;
      HttpClient.ContentType := 'application/json';
      HttpClient.Accept      := '/';
      RequestBody            := TStringStream.Create( Format(REQUEST_BODY ,
                                                                  [Telefone,
                                                                  CorpodaMensagem,
                                                                  Opcao1,
                                                                  TelefoneLigar,
                                                                  TextoBotaoTelefone,
                                                                  LinkRedirecionamento,
                                                                  TextodoLink,
                                                                  TituloMensagem,
                                                                  RodapeDaMensagem]
                                                                  ), TEncoding.UTF8 );

      try
        Response := HttpClient.Post( FURLBase+':'+FPorta  + '/api/'+ FSession +'/send-buttons',
                                     RequestBody,nil,
                                     TNetHeaders.Create(TNameValuePair.Create('Authorization', 'Bearer ' + RetornoAuth.token))
                                     );

        if Response.StatusCode in[ 200, 201 ] then
        begin
           result             := True;
           Retorno.Mensagem   := Response.ContentAsString;

        end else begin
           Result := False;
           raise Exception.Create(Response.StatusCode.ToString + ' ' + Response.StatusText + ' ' + Response.ContentAsString);
        end;

      except
        on E:Exception do
        begin
           Result := false;
           raise Exception.Create(E.Message);
        end;
      end;

    finally
      if Assigned(RequestBody) then
        FreeAndNil(RequestBody);
      if Assigned(HttpClient) then
        FreeAndNil(HttpClient);
    end;

end;

function TDTWpp.SendButtons2Opcoes(Telefone, CorpodaMensagem, TelefoneLigar,
  TextoBotaoTelefone, LinkRedirecionamento, TextodoLink, TituloMensagem,
  RodapeDaMensagem, Opcao1, Opcao2: string): Boolean;
const
  REQUEST_BODY =
  ' { ' +
  ' "phone": "%s", ' + // telefone
  ' "message": "%s", ' +  // corpo da mensagem
  ' "options": { ' +
  ' "useTemplateButtons": "true", ' +
  ' "buttons": [ ' +
  ' { ' +
  ' "id": "1", ' +
  ' "text": "%s" ' + // Opcao 1
  ' }, ' +
  ' { ' +
  ' "id": "2", ' +
  ' "phoneNumber": "%s", ' + // telefone do botao de ligar 55dddxxxxxxxx
  ' "text": "%s" ' + // texto do botao de ligar
  ' }, ' +
  ' { ' +
  ' "id": "3", ' +
  ' "url": "%s", ' + // link de redirecionamento
  ' "text": "%s" ' + // texto referente ao link
  ' }, ' +
  ' { ' +
  ' "id": "4", ' +
  ' "text": "%s" ' + // opcao 2
  ' } ' +
  ' ], ' +
  ' "title": "%s", ' +  // titulo da mensagem
  ' "footer": "%s" ' + // rodape da mensagem
  ' } ' +
  ' } ';

var
  HttpClient  : THttpClient;
  Response    : IHttpResponse;
  RequestBody : TStringStream;
  xURL        : string;
  obj         : TJSONObject;
begin
    try
      if RetornoAuth.token = '' then
          generatetoken;

      HttpClient             := THttpClient.Create;
      HttpClient.ContentType := 'application/json';
      HttpClient.Accept      := '/';
      RequestBody            := TStringStream.Create( Format(REQUEST_BODY ,
                                                                  [Telefone,
                                                                  CorpodaMensagem,
                                                                  Opcao1,
                                                                  TelefoneLigar,
                                                                  TextoBotaoTelefone,
                                                                  LinkRedirecionamento,
                                                                  TextodoLink,
                                                                  Opcao2,
                                                                  TituloMensagem,
                                                                  RodapeDaMensagem]
                                                                  ), TEncoding.UTF8 );

      try
        Response := HttpClient.Post( FURLBase+':'+FPorta  + '/api/'+ FSession +'/send-buttons',
                                     RequestBody,nil,
                                     TNetHeaders.Create(TNameValuePair.Create('Authorization', 'Bearer ' + RetornoAuth.token))
                                     );

        if Response.StatusCode in[ 200, 201 ] then
        begin
           result             := True;
           Retorno.Mensagem   := Response.ContentAsString;

        end else begin
           Result := False;
           raise Exception.Create(Response.StatusCode.ToString + ' ' + Response.StatusText + ' ' + Response.ContentAsString);
        end;

      except
        on E:Exception do
        begin
           Result := false;
           raise Exception.Create(E.Message);
        end;
      end;

    finally
      if Assigned(RequestBody) then
        FreeAndNil(RequestBody);
      if Assigned(HttpClient) then
        FreeAndNil(HttpClient);
    end;

end;

function TDTWpp.SendButtons3Opcoes(Telefone,CorpodaMensagem,TelefoneLigar,TextoBotaoTelefone,LinkRedirecionamento,TextodoLink,TituloMensagem, RodapeDaMensagem, Opcao1,Opcao2,Opcao3: string): Boolean;
const
  REQUEST_BODY =
  ' { ' +
  ' "phone": "%s", ' + // telefone
  ' "message": "%s", ' +  // corpo da mensagem
  ' "options": { ' +
  ' "useTemplateButtons": "true", ' +
  ' "buttons": [ ' +
  ' { ' +
  ' "id": "1", ' +
  ' "text": "%s" ' + // Opcao 1
  ' }, ' +
  ' { ' +
  ' "id": "2", ' +
  ' "phoneNumber": "%s", ' + // telefone do botao de ligar 55dddxxxxxxxx
  ' "text": "%s" ' + // texto do botao de ligar
  ' }, ' +
  ' { ' +
  ' "id": "3", ' +
  ' "url": "%s", ' + // link de redirecionamento
  ' "text": "%s" ' + // texto referente ao link
  ' }, ' +
  ' { ' +
  ' "id": "4", ' +
  ' "text": "%s" ' + // opcao 2
  ' }, ' +
  ' { ' +
  ' "id": "5", ' +
  ' "text": "%s" ' + // opcao 3
  ' } ' +
  ' ], ' +
  ' "title": "%s", ' +  // titulo da mensagem
  ' "footer": "%s" ' + // rodape da mensagem
  ' } ' +
  ' } ';

var
  HttpClient  : THttpClient;
  Response    : IHttpResponse;
  RequestBody : TStringStream;
  xURL        : string;
  obj         : TJSONObject;
begin
    try
      if RetornoAuth.token = '' then
          generatetoken;

      HttpClient             := THttpClient.Create;
      HttpClient.ContentType := 'application/json';
      HttpClient.Accept      := '/';
      RequestBody            := TStringStream.Create( Format(REQUEST_BODY ,
                                                                  [Telefone,
                                                                  CorpodaMensagem,
                                                                  Opcao1,
                                                                  TelefoneLigar,
                                                                  TextoBotaoTelefone,
                                                                  LinkRedirecionamento,
                                                                  TextodoLink,
                                                                  Opcao2,
                                                                  Opcao3,
                                                                  TituloMensagem,
                                                                  RodapeDaMensagem]
                                                                  ), TEncoding.UTF8 );

      try
        Response := HttpClient.Post( FURLBase+':'+FPorta  + '/api/'+ FSession +'/send-buttons',
                                     RequestBody,nil,
                                     TNetHeaders.Create(TNameValuePair.Create('Authorization', 'Bearer ' + RetornoAuth.token))
                                     );

        if Response.StatusCode in[ 200, 201 ] then
        begin
           result             := True;
           Retorno.Mensagem   := Response.ContentAsString;

        end else begin
           Result := False;
           raise Exception.Create(Response.StatusCode.ToString + ' ' + Response.StatusText + ' ' + Response.ContentAsString);
        end;

      except
        on E:Exception do
        begin
           Result := false;
           raise Exception.Create(E.Message);
        end;
      end;

    finally
      if Assigned(RequestBody) then
        FreeAndNil(RequestBody);
      if Assigned(HttpClient) then
        FreeAndNil(HttpClient);
    end;
end;

function TDTWpp.SendFile(Telefone, FileName, Mensagem,
  CaminhoDoArquivo: string): Boolean;
  var
  HttpClient      : THttpClient;
  Response        : IHttpResponse;
  xURL ,REQUEST_BODY           : string;
  obj             : TJSONObject;
  RequestBody     : TStringStream;
  sBase64         : string;
begin

    try
      sBase64 := FileToBase64(CaminhoDoArquivo);
      REQUEST_BODY := '{ "phone": "'+telefone+'","base64": "'+'data:application/'+ ExtractFileExt(FileName).Replace('.','') +';base64,' +sBase64+'","caption": "'+mensagem+'", "isGroup": false }';
      REQUEST_BODY := StringReplace( REQUEST_BODY, #13#10,'',[rfReplaceAll]);
      if RetornoAuth.token = '' then
          generatetoken;

      HttpClient             := THttpClient.Create;
      HttpClient.ContentType := 'application/json';
      HttpClient.Accept      := '/';

      RequestBody := TStringStream.Create(REQUEST_BODY, TEncoding.UTF8);
      try
        Response := HttpClient.Post( FURLBase+':'+FPorta  + '/api/'+ FSession +'/send-file-base64',
                                     RequestBody,nil,
                                     TNetHeaders.Create(TNameValuePair.Create('Authorization', 'Bearer ' + RetornoAuth.token))
                                     );

        if Response.StatusCode in[ 200, 201 ] then
        begin
           result             := True;
           Retorno.Mensagem   := Response.ContentAsString;

        end else begin
           Result := False;
           raise Exception.Create(Response.StatusCode.ToString + ' ' + Response.StatusText + ' ' + Response.ContentAsString);
        end;

      except
        on E:Exception do
        begin
           Result := false;
           raise Exception.Create(E.Message);
        end;
      end;

    finally
      if Assigned(RequestBody) then
        FreeAndNil(RequestBody);
      if Assigned(HttpClient) then
        FreeAndNil(HttpClient);
    end;
end;

function TDTWpp.SendImage(Telefone, FileName, Mensagem,
  CaminhoDoArquivo: string): Boolean;
var
  HttpClient      : THttpClient;
  Response        : IHttpResponse;
  xURL ,REQUEST_BODY           : string;
  obj             : TJSONObject;
  RequestBody     : TStringStream;
  sBase64         : string;
begin

    try
      sBase64 := FileToBase64(CaminhoDoArquivo);
      REQUEST_BODY := '{ "phone": "'+telefone+'","base64": "'+'data:image/'+ ExtractFileExt(FileName).Replace('.','') +';base64,' +sBase64+'","caption": "'+mensagem+'", "isGroup": false }';
      REQUEST_BODY := StringReplace( REQUEST_BODY, #13#10,'',[rfReplaceAll]);
      if RetornoAuth.token = '' then
          generatetoken;

      HttpClient             := THttpClient.Create;
      HttpClient.ContentType := 'application/json';
      HttpClient.Accept      := '/';

      RequestBody := TStringStream.Create(REQUEST_BODY, TEncoding.UTF8);
      try
        Response := HttpClient.Post( FURLBase+':'+FPorta  + '/api/'+ FSession +'/send-image',
                                     RequestBody,nil,
                                     TNetHeaders.Create(TNameValuePair.Create('Authorization', 'Bearer ' + RetornoAuth.token))
                                     );

        if Response.StatusCode in[ 200, 201 ] then
        begin
           result             := True;
           Retorno.Mensagem   := Response.ContentAsString;

        end else begin
           Result := False;
           raise Exception.Create(Response.StatusCode.ToString + ' ' + Response.StatusText + ' ' + Response.ContentAsString);
        end;

      except
        on E:Exception do
        begin
           Result := false;
           raise Exception.Create(E.Message);
        end;
      end;

    finally
      if Assigned(RequestBody) then
        FreeAndNil(RequestBody);
      if Assigned(HttpClient) then
        FreeAndNil(HttpClient);
    end;

end;

function TDTWpp.SendMessage(Telefone, Mensagem: string): Boolean;
const
  REQUEST_BODY = '{ "phone": "%s","message": "%s", "isGroup": false }';
var
  HttpClient  : THttpClient;
  Response    : IHttpResponse;
  RequestBody : TStringStream;
  xURL        : string;
  obj         : TJSONObject;
begin
    try
      if RetornoAuth.token = '' then
          generatetoken;

      HttpClient             := THttpClient.Create;
      HttpClient.ContentType := 'application/json';
      HttpClient.Accept      := '/';
      RequestBody := TStringStream.Create( Format(REQUEST_BODY , [Telefone,Mensagem]), TEncoding.UTF8 );

      try
        Response := HttpClient.Post( FURLBase+':'+FPorta  + '/api/'+ FSession +'/send-message',
                                     RequestBody,nil,
                                     TNetHeaders.Create(TNameValuePair.Create('Authorization', 'Bearer ' + RetornoAuth.token))
                                     );

        if Response.StatusCode in[ 200, 201 ] then
        begin
           result             := True;
           Retorno.Mensagem   := Response.ContentAsString;

        end else begin
           Result := False;
           raise Exception.Create(Response.StatusCode.ToString + ' ' + Response.StatusText + ' ' + Response.ContentAsString);
        end;

      except
        on E:Exception do
        begin
           Result := false;
           raise Exception.Create(E.Message);
        end;
      end;

    finally
      if Assigned(RequestBody) then
        FreeAndNil(RequestBody);
      if Assigned(HttpClient) then
        FreeAndNil(HttpClient);
    end;

end;

procedure TDTWpp.SetCaminhoQrCode(const Value: string);
begin
  FCaminhoQrCode := Value;
end;

procedure TDTWpp.SetEmoticons(const Value: TWPPEmitions);
begin
  FEmoticons := Value;
end;

procedure TDTWpp.SetPorta(const Value: string);
begin
  FPorta := Value;
end;

procedure TDTWpp.SetSecretKey(const Value: string);
begin
  FSecretKey := Value;
end;

procedure TDTWpp.SetSession(const Value: string);
begin
  FSession := Value;
end;

procedure TDTWpp.SetURLBase(const Value: string);
begin
  FURLBase := Value;
end;

function TDTWpp.StartSession: boolean;
const
  REQUEST_BODY = '{ "webhook": null, "waitQrCode":true }';
var
  HttpClient  : THttpClient;
  Response    : IHttpResponse;
  RequestBody : TStringStream;
  xURL        : string;
  obj         : TJSONObject;
begin
    try
      if RetornoAuth.token = '' then
          generatetoken;

      HttpClient             := THttpClient.Create;
      HttpClient.ContentType := 'application/json';
      HttpClient.Accept      := '/';
      RequestBody := TStringStream.Create(REQUEST_BODY);

      try
        Response := HttpClient.Post( FURLBase+':'+FPorta  + '/api/'+ FSession +'/start-session',
                                     RequestBody,nil,
                                     TNetHeaders.Create(TNameValuePair.Create('Authorization', 'Bearer ' + RetornoAuth.token))
                                     );

        if Response.StatusCode in[ 200, 201 ] then
        begin
           result                  := True;
           obj := TJSONObject.ParseJSONValue(TEncoding.UTF8.GetBytes( Response.ContentAsString ), 0) as TJSONObject;

           RetornoSession.status   := obj.GetValue('status').Value;
           RetornoSession.session  := obj.GetValue('session').Value;
           RetornoSession.qrcode   := obj.GetValue('qrcode').Value.Replace('data:image/png;base64,','');
           if Length(obj.GetValue('qrcode').Value.Replace('data:image/png;base64,','')) > 10 then
            if BitmapFromBase64( obj.GetValue('qrcode').Value.Replace('data:image/png;base64,','') ) then
               RetornoSession.TemQrcode := True
            else
               RetornoSession.TemQrcode := False;
        end else begin
           Result := False;
           raise Exception.Create(Response.StatusCode.ToString + ' ' + Response.StatusText + ' ' + Response.ContentAsString);
        end;

      except
        on E:Exception do
        begin
           Result := false;
           raise Exception.Create(E.Message);
        end;
      end;

    finally
      if Assigned(RequestBody) then
        FreeAndNil(RequestBody);
      if Assigned(HttpClient) then
        FreeAndNil(HttpClient);
    end;

end;

function TDTWpp.statussession: boolean;
var
  HttpClient  : THttpClient;
  Response    : IHttpResponse;
  RequestBody : TStringStream;
  xURL        : string;
  obj         : TJSONObject;
begin
    try
      if RetornoAuth.token = '' then
          generatetoken;

      HttpClient             := THttpClient.Create;
      HttpClient.ContentType := 'application/json';
      HttpClient.Accept      := '/';
      RequestBody := TStringStream.Create;

      try
        Response := HttpClient.Get( FURLBase+':'+FPorta  + '/api/'+ FSession +'/status-session',
                                     nil,
                                     TNetHeaders.Create(TNameValuePair.Create('Authorization', 'Bearer ' + RetornoAuth.token))
                                     );

        if Response.StatusCode in[ 200, 201 ] then
        begin
           result                  := True;
           obj := TJSONObject.ParseJSONValue(TEncoding.UTF8.GetBytes( Response.ContentAsString ), 0) as TJSONObject;

           RetornoSession.status   := obj.GetValue('status').Value;
           RetornoSession.session  := obj.GetValue('session').Value;
           RetornoSession.qrcode   := obj.GetValue('qrcode').Value.Replace('data:image/png;base64,','');
           if Length(obj.GetValue('qrcode').Value) > 10 then
            if BitmapFromBase64( obj.GetValue('qrcode').Value.Replace('data:image/png;base64,','') ) then
               RetornoSession.TemQrcode := True
            else
               RetornoSession.TemQrcode := False;
        end else begin
           Result := False;
           raise Exception.Create(Response.StatusCode.ToString + ' ' + Response.StatusText + ' ' + Response.ContentAsString);
        end;

      except
        on E:Exception do
        begin
           Result := false;
           raise Exception.Create(E.Message);
        end;
      end;

    finally
      if Assigned(RequestBody) then
        FreeAndNil(RequestBody);
      if Assigned(HttpClient) then
        FreeAndNil(HttpClient);
    end;
end;

end.
