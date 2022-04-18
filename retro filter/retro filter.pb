; retro filter
; by DjPoke

; decoders and encoders
UsePNGImageDecoder()
UsePNGImageEncoder()
UseJPEGImageDecoder()
UseJPEGImageEncoder()

; constantes
#MAX_PALETTES = 16
#MAX_COLORS = 160
#BOX_SIZE = 40

; functions
Declare AddColorToPalette(col)
Declare UpdatePal(p)
Declare ApplyFilter()
Declare RemoveLastColorToPalette()
Declare RemoveAllColorsToPalette()
Declare.l GetMode()

; vars
Global Dim pal(#MAX_PALETTES, #MAX_COLORS)
Global Dim cptCol(#MAX_PALETTES)

; program
If OpenWindow(0, 0, 0, 800, 600, "retro filter", #PB_Window_SystemMenu|#PB_Window_TitleBar|#PB_Window_MinimizeGadget|#PB_Window_ScreenCentered)
  If CreateMenu(0, WindowID(0))
    MenuTitle("File")
    MenuItem(1, "New"   +Chr(9)+"Ctrl+N")
    MenuItem(2, "Open"   +Chr(9)+"Ctrl+O")
    MenuItem(3, "Save"   +Chr(9)+"Ctrl+S")
    MenuItem(9, "Quit"   +Chr(9)+"Ctrl+Q")
    
    MenuTitle("Palette")
    MenuItem(11, "New Palette")
    MenuItem(12, "Save Palette")
    MenuBar()
    MenuItem(13, "Add Color"   +Chr(9)+"Ctrl+A")
    MenuItem(14, "Remove Last Color"   +Chr(9)+"Ctrl+Del")
    MenuBar()
    MenuItem(15, "Remove All Colors")
    MenuBar()
    MenuItem(16, "Save All Configuration")
    
    MenuTitle("Filter")
    MenuItem(21, "Mode 0")
    MenuItem(22, "Mode 1")
    MenuItem(23, "Mode 2")
    MenuItem(24, "Mode 3")
    
    MenuTitle("View")
    MenuItem(31, "Refresh")
    
    SetMenuItemState(0, 24, 1)
  EndIf
      
  CanvasGadget(1, 0, 200, 800, 400, #PB_Canvas_Keyboard)
  PanelGadget(2, 0, 0, 800, 200)  
  CloseGadgetList()
  
  AddKeyboardShortcut(0, #PB_Shortcut_Control | #PB_Shortcut_N, 1)
  AddKeyboardShortcut(0, #PB_Shortcut_Control | #PB_Shortcut_O, 2)
  AddKeyboardShortcut(0, #PB_Shortcut_Control | #PB_Shortcut_S, 3)
  AddKeyboardShortcut(0, #PB_Shortcut_Control | #PB_Shortcut_Q, 9)
  AddKeyboardShortcut(0, #PB_Shortcut_Control | #PB_Shortcut_A, 13)
  AddKeyboardShortcut(0, #PB_Shortcut_Control | #PB_Shortcut_Delete, 14)
  
  For j = 1 To #MAX_PALETTES
    For i = 1 To #MAX_COLORS
      pal(j, i) = RGB(255, 255, 255)
    Next
  Next
  
  ; main loop
  Repeat
    ev = WaitWindowEvent()
    
    Select ev
      Case #PB_Event_CloseWindow
        Break
      Case #PB_Event_Menu
        em = EventMenu()
        
        Select em
          Case 1
            FreeGadget(2)
            PanelGadget(2, 0, 0, 800, 200)
            CloseGadgetList()
            cptCol(p) = 0
          Case 2
            file$ = OpenFileRequester("Open...", "", "Images|*.png;*.jpg;*.jpeg;*.bmp", 0)
            
            If file$ <> ""
              If IsImage(1) : FreeImage(1) : EndIf
              
              LoadImage(1, file$)
              
              ; update the view
              StartDrawing(CanvasOutput(1))
              DrawingMode(#PB_2DDrawing_Default)
              DrawImage(ImageID(1), 0, 0, GadgetWidth(1), GadgetHeight(1))  
              StopDrawing()
              
              p = GetGadgetState(2) + 1
              g = p + 2

              If cptCol(p) > 1
                ApplyFilter()
              EndIf
            EndIf
          Case 3
            file$ = SaveFileRequester("Open...", "", "Images|*.png;*.jpg;*.jpeg;*.bmp", 0)
            
            If file$ <> ""
              ApplyFilter()
              
              a$ = LCase(GetExtensionPart(file$))
              If a$ = "" : a$ = "png" : file$ = file$ + "." + a$ : EndIf
              
              If a$ = "bmp"
                SaveImage(2, file$, #PB_ImagePlugin_BMP)
              ElseIf a$ = "png"
                SaveImage(2, file$, #PB_ImagePlugin_PNG)
              ElseIf a$ = "jpg"
                SaveImage(2, file$, #PB_ImagePlugin_JPEG)
              Else
                MessageRequester("Error", "Can't save image !")
              EndIf
            EndIf

          Case 9
            Break
          Case 11
            If CountGadgetItems(2) < #MAX_PALETTES
              OpenGadgetList(2)
              AddGadgetItem(2, -1, "Pal " + Str(CountGadgetItems(2) + 1))
              CanvasGadget(CountGadgetItems(2) + 2, 0, 0, 800, 600 - GetGadgetAttribute(2, #PB_Panel_TabHeight))
              CloseGadgetList()
              
              SetGadgetState(2, CountGadgetItems(2) - 1)
              
              UpdatePal(CountGadgetItems(2) + 2)
            Else
              MessageRequester("Error", "Too many palettes !", #PB_MessageRequester_Error)
            EndIf
          Case 13
            If CountGadgetItems(2) > 0
              col = ColorRequester()
            
              If col > -1
                AddColorToPalette(col)
              EndIf
            EndIf
          Case 14
            RemoveLastColorToPalette()
          Case 15
            RemoveAllColorsToPalette()
          Case 21, 22, 23, 24
            SetMenuItemState(0, 21, 0)
            SetMenuItemState(0, 22, 0)
            SetMenuItemState(0, 23, 0)
            SetMenuItemState(0, 24, 0)
            
            SetMenuItemState(0, em, 1)
          Case 31
            p = GetGadgetState(2) + 1
            g = p + 2

            If cptCol(p) > 1 And IsImage(1)
              ApplyFilter()
            EndIf
        EndSelect
      Case #PB_Event_Gadget
        eg = EventGadget()
        et = EventType()
        
        If eg = 1 And et = #PB_EventType_LeftClick
          p = GetGadgetState(2) + 1
          g = p + 2

          If cptCol(p) > 1 And IsImage(1)
            ApplyFilter()
          EndIf
        EndIf
    EndSelect
    
    Delay(1)
  ForEver
  CloseWindow(0)
EndIf

End

; =========================================================================================
; add a color to a palette
Procedure AddColorToPalette(col)
  p = GetGadgetState(2) + 1
  g = p + 2
  
  cptCol(p) + 1
  pal(p, cptCol(p)) = col
  
  UpdatePal(g)
EndProcedure

; remove last color from the palette
Procedure RemoveLastColorToPalette()
  p = GetGadgetState(2) + 1
  g = p + 2
  
  If cptCol(p) > 0
    cptCol(p) - 1
  EndIf
  
  UpdatePal(g)
EndProcedure

; remove all colors from the palette
Procedure RemoveAllColorsToPalette()
  p = GetGadgetState(2) + 1
  g = p + 2
  
  cptCol(p) = 0
  
  UpdatePal(g)
EndProcedure

; update the selected palette
Procedure UpdatePal(g)
  p = g - 2
  
  StartDrawing(CanvasOutput(g))
  DrawingMode(#PB_2DDrawing_Default)
  
  Box(0, 0, 800, 200, RGB(255, 255, 255))
  
  i = 0
  
  For y = 0 To (4 * #BOX_SIZE) - 1 Step #BOX_SIZE
    For x = 0 To 799 Step #BOX_SIZE
      i + 1
      If i <= cptCol(p)
        Box(x, y, #BOX_SIZE, #BOX_SIZE, RGB(0, 0, 0))
        Box(x + 1, y + 1, #BOX_SIZE - 2, #BOX_SIZE - 2, pal(p, i))
      EndIf
    Next
  Next
  StopDrawing()
EndProcedure

Procedure ApplyFilter()
  p = GetGadgetState(2) + 1
  md.l = GetMode()
  
  If IsImage(2) : FreeImage(2) : EndIf
  CreateImage(2, ImageWidth(1), ImageHeight(1))
  
  Dim pt.l(ImageWidth(1), ImageHeight(1))
  
  StartDrawing(ImageOutput(1))
  DrawingMode(#PB_2DDrawing_Default)
	For y = 0 To ImageHeight(1) - 1
	  For x = 0 To ImageWidth(1) - 1
	    pt(x, y) = Point(x, y)
	  Next
	Next
  StopDrawing()
  
  ;
  For y = 0 To ImageHeight(1) - 1
    StartDrawing(ImageOutput(2))
    DrawingMode(#PB_2DDrawing_Default)
    
    For x = 0 To ImageWidth(1) - 1
      r.l = (Round(Red(pt(x, y)) / md, #PB_Round_Down) * md) + md - 1
      g.l = (Round(Green(pt(x, y)) / md, #PB_Round_Down) * md) + md - 1
      b.l = (Round(Blue(pt(x, y)) / md, #PB_Round_Down) * md) + md - 1

			found.b = #False
			
			distr.w = 255
			distg.w = 255
			distb.w = 255
			
			memdistr.w = 255
			memdistg.w = 255
			memdistb.w = 255
			
			c.b = 0

			; find exact color
			For i = 1 To cptCol(p)
				If Red(pal(p, i)) = r And Green(pal(p, i)) = g And Blue(pal(p, i)) = b
					c = i
					found = #True

					Break
				EndIf
			Next

			; find an approximative color
			If Not found
  			For i = 1 To cptCol(p)
					distr = Abs(r - Red(pal(p, i)))
					distg = Abs(g - Green(pal(p, i)))
					distb = Abs(b - Blue(pal(p, i)))

					If distr <= memdistr And distg <= memdistg And distb <= memdistb
						memdistr = distr
						memdistg = distg
						memdistb = distb
						c = i
						
						found = #True
					EndIf
				Next
			EndIf
			
			; replace the color by the one found
			If found
			  Plot(x, y, pal(p, c))
			EndIf
			
			ev = WindowEvent()
			
			; esc to stop render
			If ev = #PB_Event_Gadget
			  eg = EventGadget()
			  
			  If eg = 1
			    If GetGadgetAttribute(1, #PB_Canvas_Key) = #pb_shortcut_escape
			      StopDrawing()
			      
			      Break(2)
			    EndIf
			  EndIf
			EndIf
		Next
					
		StopDrawing()

    ; update the view
		StartDrawing(CanvasOutput(1))
    DrawingMode(#PB_2DDrawing_Default)
    DrawImage(ImageID(2), 0, 0, GadgetWidth(1), GadgetHeight(1))  
    StopDrawing()
	Next
EndProcedure

Procedure.l GetMode()
  md.l = 0
  
  If GetMenuItemState(0, 21) = 1 : md = 64 : EndIf
  If GetMenuItemState(0, 22) = 1 : md = 32 : EndIf
  If GetMenuItemState(0, 23) = 1 : md = 16 : EndIf
  If GetMenuItemState(0, 24) = 1 : md = 8 : EndIf
  
  ProcedureReturn md
EndProcedure


; IDE Options = PureBasic 5.73 LTS (Windows - x64)
; CursorPosition = 332
; FirstLine = 312
; Folding = --
; EnableXP
; Executable = retro filter.exe