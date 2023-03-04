unit DTWpp;

interface

uses
  System.SysUtils, System.Classes, Vcl.ExtCtrls,
  System.Net.URLClient,
  System.Net.HttpClient, System.netEncoding,
  System.Net.HttpClientComponent,json,Vcl.Graphics , Soap.EncdDecd,Vcl.Imaging.pngimage;

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
    procedure SetSecretKey(const Value: string);
    procedure SetSession(const Value: string);
    procedure SetCaminhoQrCode(const Value: string);
    function BitmapFromBase64(const base64: string): Boolean;
    function FileToBase64(Arquivo : String): String;
    function StreamToBase64(STream: TMemoryStream): String;

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

  published
    property Session   : string read FSession   write SetSession;
    property SecretKey : string read FSecretKey write SetSecretKey;
    property CaminhoQrCode:string read FCaminhoQrCode write SetCaminhoQrCode;
  end;

  const
  URL_Basse = 'http://www.dtloja.com.br:30000/api';

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
        Response := HttpClient.Post( URL_Basse + '/'+ FSession +'/' + FSecretKey + '/generate-token',
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
        Response := HttpClient.Post( URL_Basse + '/'+ FSession +'/logout-session',
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

function TDTWpp.SendFile(Telefone, FileName, Mensagem,
  CaminhoDoArquivo: string): Boolean;
//const REQUEST_BODY = '{ "phone": "%s","base64": "%s","caption": "%s", "isGroup": false }';
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
      REQUEST_BODY := '{ "phone": "'+telefone+'","base64": "'+'data:application/pdf;base64,' +sBase64+'","caption": "'+mensagem+'", "isGroup": false }';
      REQUEST_BODY := StringReplace( REQUEST_BODY, #13#10,'',[rfReplaceAll]);
      if RetornoAuth.token = '' then
          generatetoken;

      HttpClient             := THttpClient.Create;
      HttpClient.ContentType := 'application/json';
      HttpClient.Accept      := '/';

      //RequestBody := TStringStream.Create( Format(REQUEST_BODY , [Telefone,'data:application/pdf;base64,'+sBase64,Mensagem]) );
      RequestBody := TStringStream.Create(REQUEST_BODY);
      try
        Response := HttpClient.Post( URL_Basse + '/'+ FSession +'/send-file-base64',
                                     RequestBody,nil,
                                     TNetHeaders.Create(TNameValuePair.Create('Authorization', 'Bearer ' + RetornoAuth.token))
                                     );

        if Response.StatusCode in[ 200, 201 ] then
        begin
           result                  := True;
          // obj := TJSONObject.ParseJSONValue(TEncoding.UTF8.GetBytes( Response.ContentAsString ), 0) as TJSONObject;

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
      RequestBody := TStringStream.Create( Format(REQUEST_BODY , [Telefone,Mensagem]) );

      try
        Response := HttpClient.Post( URL_Basse + '/'+ FSession +'/send-message',
                                     RequestBody,nil,
                                     TNetHeaders.Create(TNameValuePair.Create('Authorization', 'Bearer ' + RetornoAuth.token))
                                     );

        if Response.StatusCode in[ 200, 201 ] then
        begin
           result                  := True;
          // obj := TJSONObject.ParseJSONValue(TEncoding.UTF8.GetBytes( Response.ContentAsString ), 0) as TJSONObject;

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

procedure TDTWpp.SetSecretKey(const Value: string);
begin
  FSecretKey := Value;
end;

procedure TDTWpp.SetSession(const Value: string);
begin
  FSession := Value;
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
        Response := HttpClient.Post( URL_Basse + '/'+ FSession +'/start-session',
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
        Response := HttpClient.Get( URL_Basse + '/'+ FSession +'/status-session',
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
