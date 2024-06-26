Attribute VB_Name = "AutoCutLines"
#If VBA7 Then
  Private Declare PtrSafe Sub Sleep Lib "kernel32" (ByVal dwMilliseconds As LongPtr)
#Else
  Private Declare Sub Sleep Lib "kernel32" (ByValdwMilliseconds As Long)
#End If

Public Sub AutoCutLines()
  Nodes_TO_TSP
  START_Cut_Line_Algorithm 3#
  
  '延时500毫秒，如果电脑够快，可以调整到100ms
  Sleep 500
 '// TSP_TO_DRAW_LINES
  TSP_TO_DRAW_LINE
End Sub

Private Function Nodes_TO_TSP()
  On Error GoTo ErrorHandler
  API.BeginOpt "Nodes_TO_TSP"
  
  Set fs = CreateObject("Scripting.FileSystemObject")
  Set f = fs.CreateTextFile("C:\TSP\CDR_TO_TSP", True)

  Dim s As Shape, ssr As ShapeRange
  Set ssr = ActiveSelectionRange

  Dim TSP As String
  TSP = (ssr.Count * 4) & " " & 0 & vbNewLine

  For Each s In ssr
      lx = s.LeftX:   rx = s.RightX
      By = s.BottomY: ty = s.TopY
      TSP = TSP & lx & " " & By & vbNewLine
      TSP = TSP & lx & " " & ty & vbNewLine
      TSP = TSP & rx & " " & By & vbNewLine
      TSP = TSP & rx & " " & ty & vbNewLine
  Next s
  f.WriteLine TSP
  f.Close
  
  '// 刷新一下文件流，延时的效果
  Set f = fs.OpenTextFile("C:\TSP\CDR_TO_TSP", 1, False)
  Dim str
  str = f.ReadAll()
  f.Close
  
  API.EndOpt
Exit Function
ErrorHandler:
    Application.Optimization = False
    On Error Resume Next
End Function

'//  TSP功能画线-多线段
Private Function TSP_TO_DRAW_LINES()
  On Error GoTo ErrorHandler
  API.BeginOpt "TSP_TO_DRAW_LINES"
  
  Set fs = CreateObject("Scripting.FileSystemObject")
  Set f = fs.OpenTextFile("C:\TSP\TSP2.txt", 1, False)
  Dim str, arr, n
  Dim line As Shape
  str = f.ReadAll()
  f.Close
  Set f = fs.OpenTextFile("C:\TSP\TSP2.txt", 1, False)
  str = f.ReadAll()
  
  str = VBA.Replace(str, vbNewLine, " ")
  Do While InStr(str, "  ")
    str = VBA.Replace(str, "  ", " ")
  Loop
  
  arr = Split(str)
  For n = 2 To UBound(arr) - 1 Step 4
    x = Val(arr(n))
    Y = Val(arr(n + 1))
    x1 = Val(arr(n + 2))
    y1 = Val(arr(n + 3))

    Set line = ActiveLayer.CreateLineSegment(x, Y, x1, y1)
    set_line_color line
    
    ' 调试线条顺序
    puts x, Y, (n + 2) / 4
    
  Next
  
  ActivePage.Shapes.FindShapes(Query:="@colors.find(RGB(26, 22, 35))").CreateSelection
  ActiveSelection.Group
  ActiveSelection.Outline.SetProperties 0.2, Color:=CreateCMYKColor(0, 100, 100, 0)
  
  API.EndOpt
Exit Function
ErrorHandler:
    Application.Optimization = False
    On Error Resume Next
End Function

'// 运行裁切线算法 Cut_Line_Algorithm.py
Private Function START_Cut_Line_Algorithm(Optional ext As Double = 3)
    cmd_line = "python C:\TSP\Cut_Line_Algorithm.py" & " " & ext
    Shell cmd_line
End Function

'// 设置线条标记(颜色)
Private Function set_line_color(line As Shape)
  line.Outline.SetProperties Color:=CreateRGBColor(26, 22, 35)
End Function

Public Sub puts(x, Y, n)
  Dim st As String
  st = str(n)
  Set s = ActiveLayer.CreateArtisticText(x, Y, st)
End Sub


'//  TSP功能画线-弓形线

Public Function TSP_TO_DRAW_LINE()
  On Error GoTo ErrorHandler
  API.BeginOpt

  Set fs = CreateObject("Scripting.FileSystemObject")
  Set f = fs.OpenTextFile("C:\TSP\TSP2.txt", 1, False)
  Dim str, arr, n
  str = f.ReadAll()
  
  str = API.Newline_to_Space(str)
  arr = Split(str)
  total = Val(arr(0)) * 2
  
  ReDim ce(total) As CurveElement
  Dim crv As Curve
  
  ce(0).ElementType = cdrElementStart
  ce(0).PositionX = Val(arr(2)) ' - 3
  ce(0).PositionY = Val(arr(3)) ' - 3
  
  Dim x As Double
  Dim Y As Double
  For n = 2 To UBound(arr) - 1 Step 2
    x = Val(arr(n))
    Y = Val(arr(n + 1))
  
    ce(n / 2).ElementType = cdrElementLine
    ce(n / 2).PositionX = x
    ce(n / 2).PositionY = Y
  
  Next
  
  Set crv = CreateCurve(ActiveDocument)
  crv.CreateSubPathFromArray ce
  ActiveLayer.CreateCurve crv
  
ErrorHandler:
  API.EndOpt
End Function
