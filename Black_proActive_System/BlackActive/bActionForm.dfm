object EditActionForm: TEditActionForm
  Left = 688
  Top = 109
  Width = 255
  Height = 199
  Caption = #1050#1086#1085#1090#1088#1086#1083#1100' '#1072#1082#1090#1080#1074#1085#1086#1089#1090#1080
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poDesktopCenter
  DesignSize = (
    247
    172)
  PixelsPerInch = 96
  TextHeight = 13
  object Button1: TButton
    Left = 164
    Top = 140
    Width = 75
    Height = 25
    Cursor = crHandPoint
    Anchors = [akRight, akBottom]
    Caption = #1047#1072#1082#1088#1099#1090#1100
    TabOrder = 0
    OnClick = Button1Click
  end
  object Button2: TButton
    Left = 84
    Top = 140
    Width = 75
    Height = 25
    Cursor = crHandPoint
    Anchors = [akRight, akBottom]
    Caption = #1055#1088#1080#1085#1103#1090#1100
    TabOrder = 1
    OnClick = Button2Click
  end
  object CheckListBox1: TCheckListBox
    Left = 8
    Top = 8
    Width = 231
    Height = 122
    Anchors = [akLeft, akTop, akRight, akBottom]
    ItemHeight = 13
    Items.Strings = (
      #1050#1086#1087#1080#1088#1086#1074#1072#1085#1080#1077' '#1074' '#1089#1080#1089#1090#1077#1084#1085#1099#1077' '#1076#1080#1088#1077#1082#1090#1086#1088#1080#1080
      #1059#1076#1072#1083#1077#1085#1080#1077' '#1080#1079' '#1089#1080#1089#1090#1077#1084#1085#1099#1093' '#1076#1080#1088#1077#1082#1090#1086#1088#1080#1081
      #1057#1086#1079#1076#1072#1085#1080#1077' '#1082#1086#1087#1080#1081' (P2P.Worm)'
      #1057#1086#1079#1076#1072#1085#1080#1077' '#1087#1086#1076#1086#1079#1088#1080#1090#1077#1083#1100#1085#1099#1093' '#1092#1072#1081#1083#1086#1074)
    TabOrder = 2
  end
end
