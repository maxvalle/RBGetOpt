#tag Window
Begin Window Window1
   BackColor       =   16777215
   Backdrop        =   0
   CloseButton     =   True
   Composite       =   False
   Frame           =   0
   FullScreen      =   False
   HasBackColor    =   False
   Height          =   339
   ImplicitInstance=   True
   LiveResize      =   True
   MacProcID       =   0
   MaxHeight       =   32000
   MaximizeButton  =   False
   MaxWidth        =   32000
   MenuBar         =   -1061585724
   MenuBarVisible  =   True
   MinHeight       =   64
   MinimizeButton  =   False
   MinWidth        =   64
   Placement       =   0
   Resizeable      =   True
   Title           =   "Untitled"
   Visible         =   True
   Width           =   497
   Begin TextArea EditField1
      AcceptTabs      =   False
      Alignment       =   0
      AutoDeactivate  =   True
      BackColor       =   16777215
      Bold            =   False
      Border          =   True
      DataField       =   ""
      DataSource      =   ""
      Enabled         =   True
      Format          =   ""
      Height          =   277
      HelpTag         =   ""
      HideSelection   =   True
      Index           =   -2147483648
      InitialParent   =   ""
      Italic          =   False
      Left            =   20
      LimitText       =   0
      LockBottom      =   True
      LockedInPosition=   False
      LockLeft        =   True
      LockRight       =   True
      LockTop         =   True
      Mask            =   ""
      Multiline       =   True
      ReadOnly        =   True
      Scope           =   0
      ScrollbarHorizontal=   False
      ScrollbarVertical=   True
      Styled          =   False
      TabIndex        =   0
      TabPanelIndex   =   0
      TabStop         =   True
      Text            =   ""
      TextColor       =   0
      TextFont        =   "System"
      TextSize        =   0
      TextUnit        =   0
      Top             =   14
      Underline       =   False
      UseFocusRing    =   False
      Visible         =   True
      Width           =   457
   End
   Begin TextField EditField2
      AcceptTabs      =   False
      Alignment       =   0
      AutoDeactivate  =   True
      BackColor       =   16777215
      Bold            =   False
      Border          =   True
      CueText         =   ""
      DataField       =   ""
      DataSource      =   ""
      Enabled         =   True
      Format          =   ""
      Height          =   22
      HelpTag         =   ""
      Index           =   -2147483648
      InitialParent   =   ""
      Italic          =   False
      Left            =   20
      LimitText       =   0
      LockBottom      =   True
      LockedInPosition=   False
      LockLeft        =   True
      LockRight       =   True
      LockTop         =   False
      Mask            =   ""
      Password        =   False
      ReadOnly        =   False
      Scope           =   0
      TabIndex        =   1
      TabPanelIndex   =   0
      TabStop         =   True
      Text            =   ""
      TextColor       =   0
      TextFont        =   "System"
      TextSize        =   0
      TextUnit        =   0
      Top             =   303
      Underline       =   False
      UseFocusRing    =   True
      Visible         =   True
      Width           =   419
   End
   Begin BevelButton BevelButton1
      AcceptFocus     =   ""
      AutoDeactivate  =   True
      BackColor       =   ""
      Bevel           =   0
      Bold            =   False
      ButtonType      =   0
      Caption         =   "C"
      CaptionAlign    =   3
      CaptionDelta    =   0
      CaptionPlacement=   1
      Enabled         =   True
      HasBackColor    =   ""
      HasMenu         =   0
      Height          =   22
      HelpTag         =   ""
      Icon            =   0
      IconAlign       =   0
      IconDX          =   0
      IconDY          =   0
      Index           =   -2147483648
      InitialParent   =   ""
      Italic          =   False
      Left            =   451
      LockBottom      =   True
      LockedInPosition=   False
      LockLeft        =   False
      LockRight       =   True
      LockTop         =   False
      MenuValue       =   0
      Scope           =   0
      TabIndex        =   2
      TabPanelIndex   =   0
      TabStop         =   True
      TextColor       =   ""
      TextFont        =   "System"
      TextSize        =   0
      TextUnit        =   ""
      Top             =   303
      Underline       =   False
      Value           =   False
      Visible         =   True
      Width           =   30
   End
End
#tag EndWindow

#tag WindowCode
	#tag Method, Flags = &h0
		Sub println(msg as string)
		  editfield1.text = editfield1.text + msg + endofLine
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Test(argv() as string)
		  
		  dim c as integer
		  dim arg as string
		  dim longopts(2) as RBLongOpt
		  dim sb as new MemoryBlock(1)
		  dim g as RBGetOpt
		  dim i as integer
		  
		  longopts(0) = new RBLongOpt("help", RBLongOpt.NO_ARGUMENT, nil, asc("h"))
		  longopts(1) = new RBLongOpt("outputdir", RBLongOpt.REQUIRED_ARGUMENT, sb, asc("o"))
		  'longopts(1) = new RBLongOpt("outputdir", RBLongOpt.REQUIRED_ARGUMENT, sb, 2)
		  longopts(2) = new RBLongOpt("maximum", RBLongOpt.OPTIONAL_ARGUMENT, nil, 2)
		  
		  g = new RBGetOpt(argv, "-:bc::d:hW;", longopts)
		  g.setOpterr false // We'll do our own error handling
		  
		  c = g.getopt
		  while c <> -1
		    select case c
		    case 0
		      arg = g.getOptarg
		      println "Got long option with value '" + sb.stringValue(0, sb.size) + "' with argument " + arg
		      
		    case 1
		      println "I see you have return in order set and that " +_
		      "a non-option argv element was just found " +_
		      "with the value '" + g.getOptarg + "'"
		      
		    case 2
		      arg = g.getOptarg
		      println "I know this, but pretend I didn't"
		      println "We picked option " +_
		      longopts(g.getLongind).getName +_
		      " with value " + arg
		      
		    case asc("b")
		      println "You picked plain old option " + chr(c)
		      
		    case asc("c"), asc("d")
		      arg = g.getOptarg
		      println "You picked option '" + chr(c) + _
		      "' with argument " + arg
		      
		    case asc("h")
		      println "I see you asked for help"
		      
		    case asc("W")
		      println "Hmmm. You tried a -W with an incorrect long option name"
		      
		    case asc(":")
		      println "Doh! You need an argument for option " + chr(g.getOptopt)
		      
		    case asc("?")
		      println "The option '"  + chr(g.getOptopt) + "' is not valid"
		      
		    else
		      println "RBGetOpt() returned " + chr(c)
		      
		    end select
		    
		    
		    c = g.getopt
		  wend
		  
		  for i = g.getOptind to ubound(argv)
		    println "Non option argv element: " + argv(i)
		  next
		  
		End Sub
	#tag EndMethod


#tag EndWindowCode

#tag Events EditField2
	#tag Event
		Function KeyDown(Key As String) As Boolean
		  if key = chr(13) then
		    Test split("TestProgram "+me.text, " ")
		  end if
		End Function
	#tag EndEvent
#tag EndEvents
#tag Events BevelButton1
	#tag Event
		Sub Action()
		  editfield1.text = ""
		End Sub
	#tag EndEvent
#tag EndEvents
