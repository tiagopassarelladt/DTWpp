object FrmqrCodeWpp: TFrmqrCodeWpp
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  BorderStyle = bsSingle
  Caption = 'qrCode'
  ClientHeight = 311
  ClientWidth = 289
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnClose = FormClose
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object Image1: TImage
    Left = 8
    Top = 8
    Width = 273
    Height = 253
    Center = True
    Proportional = True
  end
  object Button1: TButton
    Left = 8
    Top = 267
    Width = 133
    Height = 25
    Cursor = crHandPoint
    Caption = 'Iniciar Sess'#227'o'
    TabOrder = 0
    OnClick = Button1Click
  end
  object Button2: TButton
    Left = 148
    Top = 267
    Width = 133
    Height = 25
    Cursor = crHandPoint
    Caption = 'Status da sess'#227'o'
    TabOrder = 1
    OnClick = Button2Click
  end
  object pnStatus: TPanel
    Left = 0
    Top = 297
    Width = 289
    Height = 14
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 2
  end
end
