VERSION 5.00
Begin {C62A69F0-16DC-11CE-9E98-00AA00574A4F} Toolbar 
   Caption         =   "Toolbar"
   ClientHeight    =   3960
   ClientLeft      =   45
   ClientTop       =   330
   ClientWidth     =   6750
   OleObjectBlob   =   "Toolbar.frx":0000
   StartUpPosition =   1  '所有者中心
End
Attribute VB_Name = "Toolbar"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False

#If VBA7 Then
    Private Declare PtrSafe Function DrawMenuBar Lib "user32" (ByVal Hwnd As Long) As Long
    Private Declare PtrSafe Function GetWindowLong Lib "user32" Alias "GetWindowLongA" (ByVal Hwnd As Long, ByVal nIndex As Long) As Long
    Private Declare PtrSafe Function SetWindowLong Lib "user32" Alias "SetWindowLongA" (ByVal Hwnd As Long, ByVal nIndex As Long, ByVal dwNewLong As Long) As Long
    Private Declare PtrSafe Function FindWindow Lib "user32" Alias "FindWindowA" (ByVal lpClassName As String, ByVal lpWindowName As String) As Long
    Private Declare PtrSafe Function GetSystemMetrics Lib "user32" (ByVal nIndex As Long) As Long
    
#Else
    Private Declare Function DrawMenuBar Lib "user32" (ByVal Hwnd As Long) As Long
    Private Declare Function GetWindowLong Lib "user32" Alias "GetWindowLongA" (ByVal Hwnd As Long, ByVal nIndex As Long) As Long
    Private Declare Function SetWindowLong Lib "user32" Alias "SetWindowLongA" (ByVal Hwnd As Long, ByVal nIndex As Long, ByVal dwNewLong As Long) As Long
    Private Declare Function FindWindow Lib "user32" Alias "FindWindowA" (ByVal lpClassName As String, ByVal lpWindowName As String) As Long
    Private Declare Function GetSystemMetrics Lib "user32" (ByVal nIndex As Long) As Long
#End If
Private Const GWL_STYLE As Long = (-16)
Private Const GWL_EXSTYLE = (-20)
Private Const WS_CAPTION As Long = &HC00000
Private Const WS_EX_DLGMODALFRAME = &H1&



Private Sub UserForm_Initialize()
  Dim IStyle As Long
  Dim Hwnd As Long
  
  Hwnd = FindWindow("ThunderDFrame", Me.Caption)

  IStyle = GetWindowLong(Hwnd, GWL_STYLE)
  IStyle = IStyle And Not WS_CAPTION
  SetWindowLong Hwnd, GWL_STYLE, IStyle
  DrawMenuBar Hwnd
  IStyle = GetWindowLong(Hwnd, GWL_EXSTYLE) And Not WS_EX_DLGMODALFRAME
  SetWindowLong Hwnd, GWL_EXSTYLE, IStyle
  
With Me
  .StartUpPosition = 0
  .Left = 400    ' 设置工具栏位置
  .Top = 55
  .Height = 30
  .Width = 336
End With

  OutlineKey = True
  OptKey = True

  ' 读取角线设置
  Bleed.text = API.GetSet("Bleed")
  Line_len.text = API.GetSet("Line_len")
  Outline_Width.text = GetSetting("262235.xyz", "Settings", "Outline_Width", "0.2")
End Sub

Private Sub UserForm_MouseDown(ByVal Button As Integer, ByVal Shift As Integer, ByVal x As Single, ByVal y As Single)
    If Button Then
        mx = x
        my = y
    End If
    
  With Me
    .Height = 30
  End With

End Sub

Private Sub UserForm_MouseMove(ByVal Button As Integer, ByVal Shift As Integer, ByVal x As Single, ByVal y As Single)
  If Button Then
    Me.Left = Me.Left - mx + x
    Me.Top = Me.Top - my + y
  End If
End Sub

Private Sub LOGO_MouseDown(ByVal Button As Integer, ByVal Shift As Integer, ByVal x As Single, ByVal y As Single)
  If Abs(x - 14) < 14 And Abs(y - 14) < 14 And Button = 2 Then
    Me.Width = 336
    OPEN_UI_BIG.Left = 322
    UI.Visible = True
    LOGO.Visible = False
    X_EXIT.Visible = False
    LEFT_BT.Visible = False
    TOP_BT.Visible = False
    Exit Sub
  End If
  
  If Button Then
      mx = x
      my = y
  End If
End Sub

Private Sub LOGO_MouseMove(ByVal Button As Integer, ByVal Shift As Integer, ByVal x As Single, ByVal y As Single)
  If Button Then
    Me.Left = Me.Left - mx + x
    Me.Top = Me.Top - my + y
  End If
End Sub

Private Sub UI_MouseDown(ByVal Button As Integer, ByVal Shift As Integer, ByVal x As Single, ByVal y As Single)
  Dim c As New Color
  ' 定义图标坐标pos
  Dim pos_x As Variant
  Dim pos_y As Variant
  pos_y = Array(14)
  pos_x = Array(14, 41, 67, 94, 121, 148, 174, 201, 228, 254, 281, 308, 334, 361, 388, 415, 441, 468, 495)

  '//扩展键按钮优先  ①右键收缩工具栏   ②右键居中页面    ③右键尺寸取整数    ④右键单色黑中线标记  ⑤右键单色黑中线标记
  If Abs(x - pos_x(0)) < 14 And Abs(y - pos_y(0)) < 14 And Button = 2 Then
    Me.Width = 30
    UI.Visible = False
    LOGO.Visible = True
    X_EXIT.Visible = True
    Exit Sub

  ElseIf Abs(x - pos_x(1)) < 14 And Abs(y - pos_y(0)) < 14 And Button = 2 Then
    Tools.居中页面
    Exit Sub

  ElseIf Abs(x - pos_x(3)) < 14 And Abs(y - pos_y(0)) < 14 And Button = 2 Then
    Tools.尺寸取整
    Exit Sub
  
  ElseIf Abs(x - pos_x(5)) < 14 And Abs(y - pos_y(0)) < 14 And Button = 2 Then
    自动中线色阶条.Auto_ColorMark_K
    Exit Sub
  
  '//分分合合把几个功能按键合并到一起，定义到右键上
  ElseIf Abs(x - pos_x(4)) < 14 And Abs(y - pos_y(0)) < 14 And Button = 2 Then
    Tools.分分合合
    Exit Sub
  
  ElseIf Abs(x - pos_x(6)) < 14 And Abs(y - pos_y(0)) < 14 And Button = 2 Then
    调用多页合并工具
  Exit Sub
  
  ElseIf Abs(x - pos_x(8)) < 14 And Abs(y - pos_y(0)) < 14 And Button = 2 Then
    '// 扩展工具栏
    Me.Height = 30 + 45
  Exit Sub
  
  End If
  
  '// 鼠标单击按钮  按工具栏上图标正常功能
  If Abs(x - pos_x(0)) < 14 And Abs(y - pos_y(0)) < 14 Then
    裁切线.start
    
  ElseIf Abs(x - pos_x(1)) < 14 And Abs(y - pos_y(0)) < 14 Then
    剪贴板尺寸建立矩形.start
    
  ElseIf Abs(x - pos_x(2)) < 14 And Abs(y - pos_y(0)) < 14 Then
    裁切线.SelectLine_to_Cropline
    
  ElseIf Abs(x - pos_x(3)) < 14 And Abs(y - pos_y(0)) < 14 Then
    拼版裁切线.arrange
    
  ElseIf Abs(x - pos_x(4)) < 14 And Abs(y - pos_y(0)) < 14 Then
    拼版裁切线.Cut_lines
    
  ElseIf Abs(x - pos_x(5)) < 14 And Abs(y - pos_y(0)) < 14 Then
    自动中线色阶条.Auto_ColorMark
    
  ElseIf Abs(x - pos_x(6)) < 14 And Abs(y - pos_y(0)) < 14 Then
    智能群组和查找.智能群组
    
  ElseIf Abs(x - pos_x(7)) < 14 And Abs(y - pos_y(0)) < 14 Then
    CQL_FIND_UI.Show 0
    
  ElseIf Abs(x - pos_x(8)) < 14 And Abs(y - pos_y(0)) < 14 Then
    Replace_UI.Show 0
    
  ElseIf Abs(x - pos_x(9)) < 14 And Abs(y - pos_y(0)) < 14 Then
    Tools.TextShape_ConvertToCurves
    
  ElseIf Abs(x - pos_x(10)) < 14 And Abs(y - pos_y(0)) < 14 Then
    LEFT_BT.Visible = True
    TOP_BT.Visible = True
    
  ElseIf Abs(x - pos_x(11)) < 14 And Abs(y - pos_y(0)) < 14 Then
    Me.Width = 30
    OPEN_UI_BIG.Left = 61
    UI.Visible = False
    LOGO.Visible = True
    X_EXIT.Visible = True
  End If

End Sub


Private Sub X_EXIT_Click()
  Unload Me    ' 关闭
End Sub

Private Sub LEFT_BT_Click()
  Tools.傻瓜火车排列
End Sub

Private Sub TOP_BT_Click()
 Tools.傻瓜阶梯排列
End Sub

Private Sub 调用多页合并工具()
  Dim value As Integer
  value = GMSManager.RunMacro("合并多页工具", "合并多页运行.run")
End Sub


Private Sub CDR_TO_TSP_Click()
  TSP.CDR_TO_TSP
End Sub

Private Sub START_TSP_Click()
  TSP.START_TSP
End Sub

Private Sub PATH_TO_TSP_Click()
  TSP.MAKE_TSP
End Sub

Private Sub QR2Vector_Click()
  Tools.QRCode_to_Vector
End Sub

Private Sub TSP_TO_DRAW_LINE_Click()
  TSP.TSP_TO_DRAW_LINE
End Sub


Private Sub BITMAP_MAKE_DOTS_Click()
  TSP.BITMAP_MAKE_DOTS
End Sub


Private Sub CBPY01_Click()
  Tools.Python脚本整理尺寸
  Me.Height = 30
End Sub

Private Sub CBPY02_Click()
  Tools.Python提取条码数字
  Me.Height = 30
End Sub

Private Sub CBPY03_Click()
  Tools.Python二维码QRCode
  Tools.QRCode_replace
End Sub


Private Sub OPEN_UI_BIG_Click()
  Unload Me
  CorelVBA.Show 0
End Sub

Private Sub Settings_Click()
  If 0 < Val(Bleed.text) * Val(Line_len.text) < 100 Then
   SaveSetting "262235.xyz", "Settings", "Bleed", Bleed.text
   SaveSetting "262235.xyz", "Settings", "Line_len", Line_len.text
   SaveSetting "262235.xyz", "Settings", "Outline_Width", Outline_Width.text
  End If

  Me.Height = 30
End Sub


'''/////////  图标鼠标左右点击功能调用   /////////'''

Private Sub Tools_Icon_Click()
  ' 调用语句
  i = GMSManager.RunMacro("CorelDRAW_VBA", "学习CorelVBA.start")
  Me.Height = 30
End Sub

'''////  选择多物件，组合然后拆分线段，为角线爬虫准备  ////'''
Private Sub Split_Segment_MouseDown(ByVal Button As Integer, ByVal Shift As Integer, ByVal x As Single, ByVal y As Single)
  If Button = 2 Then
    MsgBox "鼠标右键，功能待定"
    Exit Sub
  End If
  
  If Button Then
      Tools.Split_Segment
  Me.Height = 30
  End If
End Sub

Private Sub Split_Segment_Copy_MouseDown(ByVal Button As Integer, ByVal Shift As Integer, ByVal x As Single, ByVal y As Single)
  If Button = 2 Then
    MsgBox "鼠标右键，功能待定"
    Exit Sub
  End If
  
  If Button Then
      Tools.Split_Segment
  Me.Height = 30
  End If
End Sub

'''////  CorelDRAW 与 Adobe_Illustrator 剪贴板转换差  ////'''
Private Sub Adobe_Illustrator_MouseDown(ByVal Button As Integer, ByVal Shift As Integer, ByVal x As Single, ByVal y As Single)
  Dim value As Integer
  If Button = 2 Then
    value = GMSManager.RunMacro("AIClipboard", "CopyPaste.PasteAIFormat")
    Exit Sub
  End If
  
  If Button Then
    value = GMSManager.RunMacro("AIClipboard", "CopyPaste.CopyAIFormat")
    MsgBox "CorelDRAW 与 Adobe_Illustrator 剪贴板转换" & vbNewLine & "鼠标左键复制，鼠标右键粘贴"
  End If
End Sub

'''////  标记画框 支持容差  ////'''
Private Sub Mark_CreateRectangle_MouseDown(ByVal Button As Integer, ByVal Shift As Integer, ByVal x As Single, ByVal y As Single)
  If Button = 2 Then
    Tools.Mark_CreateRectangle True
  ElseIf Shift = fmCtrlMask Then
    Tools.Mark_CreateRectangle False
  Else
    Tools.Create_Tolerance
  End If
End Sub

''////  一键拆开多行组合的文字字符  ////'''
Private Sub Batch_Combine_MouseDown(ByVal Button As Integer, ByVal Shift As Integer, ByVal x As Single, ByVal y As Single)
  If Button = 2 Then
    Tools.Batch_Combine
    MsgBox "右键暂定功能: 智能群组后的拆开组合"
    Exit Sub
  End If
  
  If Button Then
    Tools.Take_Apart_Character
    Me.Height = 30
  End If
End Sub

