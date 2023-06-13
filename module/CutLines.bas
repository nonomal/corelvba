Attribute VB_Name = "CutLines"
'// This is free and unencumbered software released into the public domain.
'// For more information, please refer to  https://github.com/hongwenjun

'// Attribute VB_Name = "裁切线"   CutLines  2023.6.9

'// 选中多个物件批量制作四角裁切线
Public Function Batch_CutLines()
  If 0 = ActiveSelectionRange.Count Then Exit Function
  API.BeginOpt
  Bleed = API.GetSet("Bleed")
  Line_len = API.GetSet("Line_len")
  Outline_Width = API.GetSet("Outline_Width")

  '// 定义当前选择物件 分别获得 左右下上中心坐标(x,y)和尺寸信息
  Dim s1 As Shape, OrigSelection As ShapeRange, sr As New ShapeRange
  Set OrigSelection = ActiveSelectionRange

  For Each s1 In OrigSelection
    lx = s1.LeftX:      rx = s1.RightX
    By = s1.BottomY:    ty = s1.TopY
    cx = s1.CenterX:    cy = s1.CenterY
    sw = s1.SizeWidth:  sh = s1.SizeHeight
    
    '//  添加裁切线，分别左下-右下-左上-右上
    Dim s2, s3, s4, s5, s6, s7, s8, s9 As Shape
    Set s2 = ActiveLayer.CreateLineSegment(lx - Bleed, By, lx - (Bleed + Line_len), By)
    Set s3 = ActiveLayer.CreateLineSegment(lx, By - Bleed, lx, By - (Bleed + Line_len))

    Set s4 = ActiveLayer.CreateLineSegment(rx + Bleed, By, rx + (Bleed + Line_len), By)
    Set s5 = ActiveLayer.CreateLineSegment(rx, By - Bleed, rx, By - (Bleed + Line_len))

    Set s6 = ActiveLayer.CreateLineSegment(lx - Bleed, ty, lx - (Bleed + Line_len), ty)
    Set s7 = ActiveLayer.CreateLineSegment(lx, ty + Bleed, lx, ty + (Bleed + Line_len))

    Set s8 = ActiveLayer.CreateLineSegment(rx + Bleed, ty, rx + (Bleed + Line_len), ty)
    Set s9 = ActiveLayer.CreateLineSegment(rx, ty + Bleed, rx, ty + (Bleed + Line_len))

    '// 选中裁切线 群组 设置线宽和注册色
    ActiveDocument.AddToSelection s2, s3, s4, s5, s6, s7, s8, s9
    ActiveSelection.group
    sr.Add ActiveSelection
  Next s1

  '// 设置线宽和颜色，再选择
   sr.SetOutlineProperties Outline_Width
   sr.SetOutlineProperties Color:=CreateRegistrationColor
   sr.AddToSelection
   
  API.EndOpt
End Function


Sub test_MarkLines()
  Dimension_MarkLines cdrAlignLeft, True
'  Dimension_MarkLines cdrAlignTop, True
End Sub

'// 标注尺寸标记线
Public Function Dimension_MarkLines(Optional ByVal mark As cdrAlignType = cdrAlignTop, Optional ByVal mirror As Boolean = False)
  If 0 = ActiveSelectionRange.Count Then Exit Function
  API.BeginOpt
  Bleed = API.GetSet("Bleed")
  Line_len = API.GetSet("Line_len")
  Outline_Width = API.GetSet("Outline_Width")

  '// 定义当前选择物件 分别获得 左右下上中心坐标(x,y)和尺寸信息
  Dim s As Shape, s1 As Shape, OrigSelection As ShapeRange, sr As New ShapeRange
  Set OrigSelection = ActiveSelectionRange

  For Each s1 In OrigSelection
    lx = s1.LeftX:      rx = s1.RightX
    By = s1.BottomY:    ty = s1.TopY
    
    '//  添加使用 左-上 标注尺寸标记线
    Dim s2, s6, s7, s8, s9 As Shape
    
    If mark = cdrAlignTop Then
      Set s7 = ActiveLayer.CreateLineSegment(lx, ty + Bleed, lx, ty + (Bleed + Line_len))
      Set s9 = ActiveLayer.CreateLineSegment(rx, ty + Bleed, rx, ty + (Bleed + Line_len))
      sr.Add s7: sr.Add s9
    Else
      Set s2 = ActiveLayer.CreateLineSegment(lx - Bleed, By, lx - (Bleed + Line_len), By)
      Set s6 = ActiveLayer.CreateLineSegment(lx - Bleed, ty, lx - (Bleed + Line_len), ty)
      sr.Add s2: sr.Add s6
    End If
  Next s1

  '// 获得页面中心点 x,y
'  px = ActiveDocument.Pages.First.CenterX
'  py = ActiveDocument.Pages.First.CenterY
  '// 物件范围边界
  px = OrigSelection.LeftX
  py = OrigSelection.TopY
  mpx = OrigSelection.RightX
  mpy = OrigSelection.BottomY
  
  '// 页面边缘对齐
  For Each s In sr
    If mark = cdrAlignTop Then
      s.TopY = py + Line_len + Bleed
    Else
      s.LeftX = px - Line_len - Bleed
    End If
  Next s
  
  '// 简单删除重复
  RemoveDuplicates sr
  
  '// 设置线宽和颜色，再选择
   sr.SetOutlineProperties Outline_Width
   sr.SetOutlineProperties Color:=CreateCMYKColor(80, 40, 0, 20)
   sr.AddToSelection
   
   If mirror Then
    If mark = cdrAlignTop Then
      sr.BottomY = mpy - Line_len - Bleed
    Else
      sr.RightX = mpx + Line_len + Bleed
    End If
   End If
   
  API.EndOpt
End Function

 '// 简单删除重复线算法
Private Function RemoveDuplicates(sr As ShapeRange)
  Dim s As Shape, cnt As Integer, rms As New ShapeRange
  cnt = 1
  
  #If VBA7 Then
     sr.Sort " @shape1.Top * 100 - @shape1.Left > @shape2.Top * 100 - @shape2.Left"
  #Else
    ' X4 不支持 ShapeRange.sort
  #End If

  For Each s In sr
    If cnt > 1 Then
      If Check_duplicate(sr(cnt - 1), sr(cnt)) Then rms.Add sr(cnt)
    End If
    s.Name = "DMKLine"
    cnt = cnt + 1
  Next s
  
  rms.Delete
End Function

 '// 检查重复算法
Private Function Check_duplicate(s1 As Shape, s2 As Shape) As Boolean
  Check_duplicate = False
  Jitter = 0.1
  X = Abs(s1.CenterX - s2.CenterX)
  Y = Abs(s1.CenterY - s2.CenterY)
  w = Abs(s1.SizeWidth - s2.SizeWidth)
  h = Abs(s1.SizeHeight - s2.SizeHeight)
  If X < Jitter And Y < Jitter And w < Jitter And h < Jitter Then
    Check_duplicate = True
  End If
End Function


'// 单线条转裁切线 - 放置到页面四边
Public Function SelectLine_to_Cropline()
  If 0 = ActiveSelectionRange.Count Then Exit Function
  '// 代码运行时关闭窗口刷新
  Application.Optimization = True
  ActiveDocument.Unit = cdrMillimeter
  
  ActiveDocument.BeginCommandGroup  '一步撤消'
  
  '// 获得页面中心点 x,y
  px = ActiveDocument.Pages.First.CenterX
  py = ActiveDocument.Pages.First.CenterY
  Bleed = API.GetSet("Bleed")
  Line_len = API.GetSet("Line_len")
  Outline_Width = API.GetSet("Outline_Width")
  
  Dim s As Shape
  Dim line As Shape
  
  '// 遍历选择的线条
  For Each s In ActiveSelection.Shapes
  
    lx = s.LeftX
    rx = s.RightX
    By = s.BottomY
    ty = s.TopY
    
    cx = s.CenterX
    cy = s.CenterY
    sw = s.SizeWidth
    sh = s.SizeHeight
   
   '// 判断横线(高度小于宽度)，在页面左边还是右边
   If sh <= sw Then
    s.Delete
    If cx < px Then
        Set line = ActiveLayer.CreateLineSegment(0, cy, 0 + Line_len, cy)
    Else
        Set line = ActiveLayer.CreateLineSegment(px * 2, cy, px * 2 - Line_len, cy)
    End If
   End If
 
   '// 判断竖线(高度大于宽度)，在页面下边还是上边
   If sh > sw Then
    s.Delete
    If cy < py Then
        Set line = ActiveLayer.CreateLineSegment(cx, 0, cx, 0 + Line_len)
    Else
        Set line = ActiveLayer.CreateLineSegment(cx, py * 2, cx, py * 2 - Line_len)
    End If
   End If

    line.Outline.SetProperties Outline_Width
    line.Outline.SetProperties Color:=CreateRegistrationColor
  Next s
  
  ActiveDocument.EndCommandGroup
  '// 代码操作结束恢复窗口刷新
  Application.Optimization = False
  ActiveWindow.Refresh
  Application.Refresh
End Function
