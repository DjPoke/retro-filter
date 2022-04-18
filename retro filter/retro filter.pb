; retro filter
; by DjPoke

; decoders and encoders
UsePNGImageDecoder()
UsePNGImageEncoder()
UseJPEGImageDecoder()
UseJPEGImageEncoder()

; constantes
#MAX_PALETTES = 16
#MAX_COLORS = 256
#BOX_SIZE = 40

; functions
Declare AddColorToPalette(col)
Declare UpdatePal(p)

; vars
opened = #False

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
            opened = #False
            
            FreeGadget(2)
            PanelGadget(2, 0, 0, 800, 200)
            CloseGadgetList()
          Case 2
            file$ = OpenFileRequester("Open...", "", "Images|*.png;*.jpg;*.jpeg;*.bmp", 0)
            
            If file$ <> ""
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
  For y = 0 To 199 Step #BOX_SIZE
    For x = 0 To 799 Step #BOX_SIZE
      i + 1
      Box(x, y, #BOX_SIZE, #BOX_SIZE, pal(p, i))
    Next
  Next
  StopDrawing()
EndProcedure

; IDE Options = PureBasic 5.73 LTS (Windows - x64)
; CursorPosition = 48
; FirstLine = 27
; Folding = -
; EnableXP