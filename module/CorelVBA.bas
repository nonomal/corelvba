Attribute VB_Name = "CORELVBA"
Public Sub Start()
  Toolbar.Show 0
'  CorelVBA.show 0
'  MsgBox "请给我支持!" & vbNewLine & "您的支持，我才能有动力添加更多功能." & vbNewLine & "蘭雅CorelVBA中秋节版" & vbNewLine & "coreldrawvba插件交流群  8531411"
'  Speak_Msg "感谢您使用 蘭雅VBA工具"
End Sub

Sub Start_Dimension()
  '// 尺寸标注增强版
  MakeSizePlus.Show 0
End Sub

Public Sub Init_StartButton()
  SaveSetting "LYVBA", "Settings", "StartButton", "0"
  MsgBox "Please Restart CorelDRAW!"
End Sub

