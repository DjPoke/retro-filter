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
    MenuItem(11, "New")
    MenuItem(12, "Save")
    MenuBar()
    MenuItem(13, "Add Color")
    MenuBar()
    MenuItem(19, "Save Configuration")
  EndIf
      
  CanvasGadget(1, 0, 200, 800, 400)
  PanelGadget(2, 0, 0, 800, 200)  
  CloseGadgetList()
  
  AddKeyboardShortcut(0, #PB_Shortcut_Control | #PB_Shortcut_N, 1)
  AddKeyboardShortcut(0, #PB_Shortcut_Control | #PB_Shortcut_O, 2)
  AddKeyboardShortcut(0, #PB_Shortcut_Control | #PB_Shortcut_S, 3)
  AddKeyboardShortcut(0, #PB_Shortcut_Control | #PB_Shortcut_Q, 9)
  
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
          Case 9
            Break
          Case 11
            If CountGadgetItems(2) < #MAX_PALETTES
              OpenGadgetList(2)
              AddGadgetItem(2, -1, "Pal " + Str(CountGadgetItems(2) + 1))
              CanvasGadget(CountGadgetItems(2) + 2, 0, 0, 800, 600 - GetGadgetAttribute(2, #PB_Panel_TabHeight))
              CloseGadgetList()
              
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
        EndSelect
      Case #PB_Event_Gadget
        eg = EventGadget()
        et = EventType()
        
        If eg = 1
          p = GetGadgetState(2) + 1
          g = p + 2

          If cptCol(p) > 1 And IsImage(1) And et = #PB_Event_LeftClick
            ApplyFilter()
          EndIf
        EndIf
    EndSelect
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

; update the selected palette
Procedure UpdatePal(g)
  p = g - 2

  StartDrawing(CanvasOutput(g))
  DrawingMode(#PB_2DDrawing_Default)
  i = 0
  For y = 0 To (4 * #BOX_SIZE) - 1 Step #BOX_SIZE
    For x = 0 To 799 Step #BOX_SIZE
      i + 1
      Box(x, y, #BOX_SIZE, #BOX_SIZE, RGB(0, 0, 0))
      Box(x + 1, y + 1, #BOX_SIZE - 2, #BOX_SIZE - 2, pal(p, i))
    Next
  Next
  StopDrawing()
EndProcedure

Procedure ApplyFilter()
  p = GetGadgetState(2) + 1
  g = p + 2
  
  CreateImage(2, ImageWidth(1), ImageHeight(1))
    
	For y = 0 To ImageHeight(1) - 1
	  For x = 0 To ImageWidth(1) - 1
  	  StartDrawing(ImageOutput(1))
      DrawingMode(#PB_2DDrawing_Default)
      c = Point(x, y)
      StopDrawing()
      
  	  StartDrawing(ImageOutput(2))
      DrawingMode(#PB_2DDrawing_Default)
      
      r = Red(c)
      g = Green(c)
      b = Blue(c)

			found = #False
			
			distr = 255
			distg = 255
			distb = 255
			
			memdistr = 255
			memdistg = 255
			memdistb = 255
			
			c = 0

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
		
		  StopDrawing()
		Next

    ; update the view
    StartDrawing(CanvasOutput(1))
    DrawingMode(#PB_2DDrawing_Default)
    DrawImage(ImageID(2), 0, 0, GadgetWidth(1), GadgetHeight(1))  
    StopDrawing()
	Next
  
  FreeImage(2)
EndProcedure

; IDE Options = PureBasic 5.73 LTS (Windows - x64)
; CursorPosition = 11
; FirstLine = 3
; Folding = -
; EnableXP
; Executable = retro filter.exe