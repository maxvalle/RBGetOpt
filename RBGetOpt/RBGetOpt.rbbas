#tag Class
Protected Class RBGetOpt
	#tag Method, Flags = &h1
		Protected Function buildargv(cmdLine as string) As String()
		  
		  // Build the argv() array from a plain command line string
		  
		  dim argv(-1) as string
		  dim appName as string = app.executableFile.name
		  dim nameStart as integer
		  dim argStart as integer
		  dim c as integer
		  
		  do
		    c = instr(c+1, cmdLine, appName)
		    if c <> 0 then
		      nameStart = c
		    end if
		  loop until c = 0
		  
		  argStart = instr(nameStart+appName.len, cmdLine, " ")+1
		  argv = split(mid(cmdLine, argStart), " ")
		  argv.insert 0, appName
		  
		  return argv
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Function checkLongOption() As Integer
		  
		  // Check to see if an option is a valid long option.  Called by getopt()
		  
		  dim pfound as RBLongOpt
		  dim nameend as integer
		  dim ambig as boolean
		  dim exact as boolean
		  dim i as integer
		  dim n as integer
		  
		  longopt_handled = true
		  ambig = false
		  exact = false
		  longind = -1
		  
		  nameend = instr(nextchar, "=")-1
		  if nameend = -1 then
		    nameend = len(nextchar)
		  end if
		  
		  // Test all long options for either exact match or abbreviated matches
		  n = ubound(long_options)
		  for i = 0 to n
		    if left(long_options(i).getName, nameend) = left(nextchar, nameend) then
		      if long_options(i).getName = left(nextchar, nameend) then
		        // Exact match found
		        pfound = long_options(i)
		        longind = i
		        exact = true
		        exit
		      elseif pfound = nil then
		        // First nonexact match found
		        pfound = long_options(i)
		        longind = i
		      else
		        // Second or later nonexact match found
		        ambig = true
		      end if
		    end if
		  next
		  
		  // Print out an error if the option specified was ambiguous
		  if ambig and not exact then
		    #if not TargetHasGUI
		      if opterr then
		        StdErr.WriteLine Replace(Replace(kErrorAmbiguous, "{0}", progname), "{1}", argv(optind))
		      end if
		    #endif
		    
		    nextchar = ""
		    optopt = 0
		    optind = optind+1
		    
		    return asc("?")
		  end if
		  
		  if pfound <> nil then
		    optind = optind+1
		    
		    if nameend <> len(nextchar) then
		      if pfound.GetHasArg <> RBLongOpt.NO_ARGUMENT then
		        if len(mid(nextchar, nameend)) > 1 then
		          optarg = mid(nextchar, nameend+2)
		        else
		          optarg = ""
		        end if
		      else
		        #if not TargetHasGUI
		          if opterr then
		            if left(me.argv(optind - 1), 2) = "--" then
		              StdErr.WriteLine Replace(Replace(kErrorArguments1, "{0}", progname), "{1}", pfound.getName)
		            else
		              StdErr.WriteLine Replace(Replace(Replace(kErrorArguments2, "{0}", progname), "{1}", left(argv(optind-1), 1)), "{2}", pfound.getName)
		            end if
		          end if
		        #endif
		        
		        nextchar = ""
		        optopt = pfound.GetVal
		        
		        return asc("?")
		      end if
		    elseif pfound.GetHasArg = RBLongOpt.REQUIRED_ARGUMENT then
		      if optind < ubound(argv)+1 then
		        optarg = argv(optind)
		        optind = optind+1
		      else
		        #if not TargetHasGUI
		          if opterr then
		            StdErr.WriteLine Replace(Replace(kErrorRequires1, "{0}", progname), "{1}", argv(optind-1))
		          end if
		        #endif
		        
		        nextchar = ""
		        optopt = pfound.GetVal
		        if left(optstring, 1) = ":" then
		          return asc(":")
		        else
		          return asc("?")
		        end if
		      end if
		    end if
		    
		    nextchar = ""
		    
		    if pfound.getFlag <> nil then
		      pfound.getFlag.Size = 1
		      pfound.getFlag.byte(0) = pfound.getVal
		      
		      return 0
		    end if
		    
		    return pfound.getVal
		  end if
		  
		  longopt_handled = false
		  
		  return 0
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Constructor(argv() as string, optstring as string)
		  dim dummy(-1) as RBLongOpt
		  me.Constructor argv, optstring, dummy, false
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Constructor(argv() as string, optstring as string, long_options() as RBLongOpt)
		  me.Constructor argv, optstring, long_options, false
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Constructor(in_argv() as string, in_optstring as string, in_long_options() as RBLongOpt, in_long_only as boolean)
		  
		  // Set initial default values
		  optind = 0
		  opterr = true
		  optopt = asc("?")
		  first_nonopt = 1
		  last_nonopt = 1
		  endparse = false
		  
		  me.argv = in_argv
		  // Get the program name and remove it from argv
		  me.progname = argv(0)
		  me.argv.remove 0
		  
		  // Remove last element of argv if null
		  if me.argv(ubound(argv)) = "" then me.argv.remove ubound(argv)
		  
		  me.optstring = in_optstring
		  if len(me.optstring) = 0 then me.optstring = " "
		  me.long_options = in_long_options
		  me.long_only = in_long_only
		  
		  posixly_correct = (system.environmentVariable("POSIXLY_CORRECT") <> "")
		  
		  // Determine how to handle the ordering of options and non-options
		  if left(optstring, 1) = "-" then
		    ordering = RETURN_IN_ORDER
		    if len(me.optstring) > 1 then
		      me.optstring = mid(me.optstring, 2)
		    end if
		  elseIf left(optstring, 1) = "+" then
		    ordering = REQUIRE_ORDER
		    if len(me.optstring) > 1 then
		      me.optstring = mid(me.optstring, 2)
		    end if
		  elseif posixly_correct then
		    ordering = REQUIRE_ORDER
		  else
		    ordering = PERMUTE // The normal default case
		  end if
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Constructor(argv as string, optstring as string)
		  dim dummy(-1) as RBLongOpt
		  me.Constructor buildargv(argv), optstring, dummy, false
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Constructor(argv as string, optstring as string, long_options() as RBLongOpt)
		  me.Constructor buildargv(argv), optstring, long_options, false
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Constructor(argv as string, optstring as string, long_options() as RBLongOpt, long_only as boolean)
		  me.Constructor buildargv(argv), optstring, long_options, long_only
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Sub exchange(in_argv() as string)
		  
		  // Exchange the shorter segment with the far end of the longer segment.
		  // That puts the shorter segment into the right place.
		  // It leaves the longer segment in the right place overall,
		  // but it consists of two parts that need to be swapped next.
		  // This method is used by getopt() for argument permutation.
		  
		  dim bottom as integer = first_nonopt
		  dim middle as integer = last_nonopt
		  dim top as integer = optind
		  dim tem as string
		  dim seglen as integer
		  dim i as integer
		  dim n as integer
		  
		  while top > middle and middle > bottom
		    
		    if top - middle > middle - bottom then
		      
		      // Bottom segment is the short one.
		      seglen = middle - bottom
		      
		      // Swap it with the top part of the top segment.
		      n = seglen-1
		      for i = 0 to n
		        tem = in_argv(bottom + i)
		        in_argv(bottom + i) = in_argv(top - (middle - bottom) + i)
		        in_argv(top - (middle - bottom) + i) = tem
		      next
		      
		      // Exclude the moved bottom segment from further swapping.
		      top = top - seglen
		      
		    else
		      
		      // Top segment is the short one.
		      seglen = top - middle
		      
		      // Swap it with the bottom part of the bottom segment.
		      n = seglen-1
		      for i = 0 to n
		        tem = in_argv(bottom + i)
		        in_argv(bottom + i) = in_argv(middle + i)
		        in_argv(middle + i) = tem
		      next
		      
		      // Exclude the moved top segment from further swapping.
		      bottom = bottom + seglen
		      
		    end if
		    
		  wend
		  
		  // Update records for the slots the non-options now occupy.
		  first_nonopt = first_nonopt + (optind - last_nonopt)
		  last_nonopt = optind
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function getLongInd() As Integer
		  return me.longind
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function getopt() As Integer
		  
		  // This method returns a char that is the current option that has been
		  // parsed from the command line.  If the option takes an argument, then
		  // the internal variable 'optarg' is set which is a String representing
		  // the the value of the argument.  This value can be retrieved by the
		  // caller using the getOptarg() method.  If an invalid option is found,
		  // an error message is printed and a '?' is returned.  The name of the
		  // invalid option character can be retrieved by calling the getOptopt()
		  // method.  When there are no more options to be scanned, this method
		  // returns -1.  The index of first non-option element in argv can be
		  // retrieved with the getOptind() method.
		  
		  
		  dim c as integer
		  dim temp as string
		  
		  optarg = ""
		  
		  if endparse then
		    return -1
		  end if
		  
		  if nextchar = "" then
		    // If we have just processed some options following some non-options,
		    //  exchange them so that the options come first.
		    if last_nonopt > optind then
		      last_nonopt = optind
		    end if
		    if first_nonopt > optind then
		      first_nonopt = optind
		    end if
		    
		    if ordering = PERMUTE then
		      // If we have just processed some options following some non-options,
		      // exchange them so that the options come first.
		      if (first_nonopt <> last_nonopt) and (last_nonopt <> optind) then
		        exchange(argv)
		      elseif last_nonopt <> optind then
		        first_nonopt = optind
		      end if
		      
		      // Skip any additional non-options
		      // and extend the range of non-options previously skipped.
		      //           while optind < argv.length && (argv[optind].equals("") ||
		      //             (argv[optind].charAt(0) != '-') || argv[optind].equals("-"))
		      while optind < ubound(argv)+1 and (argv(optind) = "" or (left(argv(optind), 1) <> "-") or argv(optind) = "-")
		        optind = optind+1
		      wend
		      
		      last_nonopt = optind
		    end if
		    
		    // The special ARGV-element `--' means premature end of options.
		    // Skip it like a null option,
		    // then exchange with previous non-options as if it were an option,
		    // then skip everything else like a non-option.
		    if optind <> ubound(argv)+1 and argv(optind) = "--" then
		      optind = optind+1
		      
		      if first_nonopt <> last_nonopt and last_nonopt <> optind then
		        exchange argv
		      elseif first_nonopt = last_nonopt then
		        first_nonopt = optind
		      end if
		      
		      last_nonopt = ubound(argv)+1
		      
		      optind = ubound(argv)+1
		    end if
		    
		    // If we have done all the ARGV-elements, stop the scan
		    // and back over any non-options that we skipped and permuted.
		    if optind = ubound(argv)+1 then
		      // Set the next-arg-index to point at the non-options
		      // that we previously skipped, so the caller will digest them.
		      if first_nonopt <> last_nonopt then
		        optind = first_nonopt
		      end if
		      
		      return -1
		    end if
		    
		    // If we have come to a non-option and did not permute it,
		    // either stop the scan or describe it to the caller and pass it by.
		    if argv(optind) = "" or left(argv(optind), 1) <> "-" or argv(optind) = "-" then
		      if ordering = REQUIRE_ORDER then
		        return -1
		      end if
		      
		      optarg = argv(optind)
		      optind = optind+1
		      
		      return 1
		    end if
		    
		    // We have found another option-ARGV-element.
		    // Skip the initial punctuation.
		    if left(argv(optind), 2) = "--" then
		      nextchar = mid(argv(optind), 3)
		    else
		      nextchar = mid(argv(optind), 2)
		    end if
		  end if
		  
		  // Decode the current option-ARGV-element.
		  
		  // Check whether the ARGV-element is a long option.
		  //
		  // If long_only and the ARGV-element has the form "-f", where f is
		  // a valid short option, don' t consider it an abbreviated form of
		  // a long option that starts with f.  Otherwise there would be no
		  // way to give the -f short option.
		  //
		  // On the other hand, if there's a long option "fubar" and
		  // the ARGV-element is "-fu", do consider that an abbreviation of
		  // the long option, just like "--fu", and not "-f" with arg "u".
		  //
		  // This distinction seems to be the most useful approach.
		  if (ubound(long_options) > -1) and (left(argv(optind),2) = "--" _
		    or (long_only and ((argv(optind).len  > 2) or _
		    (instr(optstring, mid(argv(optind), 2, 1)) = 0)))) then
		    
		    c = checkLongOption
		    
		    if longopt_handled then
		      return c
		    end if
		    
		    // Can't find it as a long option.  If this is not getopt_long_only,
		    // or the option starts with '--' or is not a valid short
		    // option, then it's an error.
		    // Otherwise interpret it as a short option.
		    if not long_only or left(argv(optind), 2) = "--" or instr(optstring, left(nextchar, 1)) = 0 then
		      
		      #if not TargetHasGUI
		        if opterr then
		          if left(argv(optind), 2) = "--" then
		            StdErr.WriteLine Replace(Replace(kErrorUnrecognized1, "{0}", progname), "{1}", nextchar)
		          else
		            StdErr.WriteLine Replace(Replace(Replace(kErrorUnrecognized2, "{0}", progname), "{1}", left(argv(optind),1)), "{2}", nextchar)
		          end if
		        end if
		      #endif
		      
		      nextchar = ""
		      optind = optind +1
		      optopt = 0
		      
		      return asc("?")
		    end if
		  end if
		  
		  // Look at and handle the next short option-character
		  c = asc(left(nextchar, 1))
		  if (nextchar.len > 1) then
		    nextchar = mid(nextchar, 2)
		  else
		    nextchar = ""
		  end if
		  
		  temp = ""
		  if instr(optstring, chr(c)) <> 0 then
		    temp = mid(optstring, instr(optstring, chr(c)))
		  end if
		  
		  if nextchar = "" then
		    optind = optind + 1
		  end if
		  
		  if temp = "" or c = asc(":") then
		    #if not TargetHasGUI
		      if opterr then
		        if posixly_correct then
		          // 1003.2 specifies the format of this message
		          StdErr.WriteLine Replace(Replace(kErrorIllegal, "{0}", progname), "{1}", chr(c))
		        else
		          StdErr.WriteLine Replace(Replace(kErrorInvalid, "{0}", progname), "{1}", chr(c))
		        end if
		      end if
		    #endif
		    
		    optopt = c
		    
		    return asc("?")
		  end if
		  
		  // Convenience. Treat POSIX -W foo same as long option --foo
		  if left(temp, 1) = "W" and temp.len > 1 and mid(temp, 2, 1) = ";" then
		    if nextchar <> "" then
		      optarg = nextchar
		      // No further cars in this argv element and no more argv elements
		    elseif optind = ubound(argv)+1 then
		      #if not TargetHasGUI
		        if opterr then
		          // 1003.2 specifies the format of this message.
		          StdErr.WriteLine Replace(Replace(kErrorRequires2, "{0}", progname), "{1}", chr(c))
		        end if
		      #endif
		      
		      optopt = c
		      if left(optstring, 1) = ":" then
		        return asc(":")
		      else
		        return asc("?")
		      end if
		      
		    else
		      // We already incremented 'optind' once;
		      // increment it again when taking next ARGV-elt as argument.
		      nextchar = argv(optind)
		      optarg  = argv(optind)
		    end if
		    
		    c = checkLongOption
		    
		    if longopt_handled then
		      return c
		    else
		      // Let the application handle it
		      nextchar = ""
		      optind = optind + 1
		      return asc("W")
		    end if
		  end if
		  
		  if temp.len > 1 and mid(temp, 2, 1) = ":" then
		    if temp.len > 2 and mid(temp, 3, 1) = ":" then
		      // This is an option that accepts an argument optionally
		      if nextchar <> "" then
		        optarg = nextchar
		        optind = optind + 1
		      else
		        optarg = ""
		      end if
		      
		      nextchar = ""
		    else
		      if nextchar <> "" then
		        optarg = nextchar
		        optind = optind + 1
		      elseif optind = ubound(argv)+1 then
		        #if not TargetHasGUI
		          if opterr then
		            // 1003.2 specifies the format of this message
		            StdErr.WriteLine Replace(Replace(kErrorRequires2, "{0}", progname), "{1}", chr(c))
		          end if
		        #endif
		        
		        optopt = c
		        
		        if left(optstring, 1) = ":" then
		          return asc(":")
		        else
		          return asc("?")
		        end if
		      else
		        optarg = argv(optind)
		        optind = optind + 1
		        
		        // Ok, here's an obscure Posix case.  If we have o:, and
		        // we get -o -- foo, then we're supposed to skip the --,
		        // end parsing of options, and make foo an operand to -o.
		        // Only do this in Posix mode.
		        if posixly_correct and optarg = "--" then
		          // If end of argv, error out
		          if optind = ubound(argv)+1 then
		            #if not TargetHasGUI
		              if opterr then
		                // 1003.2 specifies the format of this message
		                StdErr.WriteLine Replace(Replace(kErrorRequires2, "{0}", progname), "{1}", chr(c))
		              end if
		            #endif
		            
		            optopt = c
		            
		            if left(optstring, 1) = ":" then
		              return asc(":")
		            else
		              return asc("?")
		            end if
		            
		          end if
		          
		          // Set new optarg and set to end
		          // Don't permute as we do on -- up above since we
		          // know we aren't in permute mode because of Posix.
		          optarg = argv(optind)
		          optind = optind + 1
		          first_nonopt = optind
		          last_nonopt = ubound(argv)+1
		          endparse = true
		        end if
		      end if
		      
		      nextchar = ""
		      
		    end if
		  end if
		  
		  return c
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function getOptarg() As String
		  return me.optarg
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function getOptind() As Integer
		  return me.optind
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function getOptopt() As Integer
		  return me.optopt
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub setArgv(in_argv() as string)
		  argv = in_argv
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub setOpterr(in_opterr as boolean)
		  me.opterr = in_opterr
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub setOptind(in_optind as integer)
		  me.optind = in_optind
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub setOptstring(in_optstring as string)
		  if len(in_optstring) = 0 then
		    me.optstring = " "
		  else
		    me.optstring = in_optstring
		  end if
		End Sub
	#tag EndMethod


	#tag Note, Name = Info
		
		RBGetOpt
		REALbasic class to handle parsinge of command line args
		
		Copyright (c)2006-2010, Massimo Valle
		All rights reserved.
		
		Redistribution and use in source and binary forms, with or without modification,
		are permitted provided that the following conditions are met:
		- Redistributions of source code must retain the above copyright notice,
		this list of conditions and the following disclaimer.
		- Redistributions in binary form must reproduce the above copyright notice,
		this list of conditions and the following disclaimer in the documentation and/or
		other materials provided with the distribution.
		- Neither the name of the author nor the names of its contributors may be used to
		endorse or promote products derived from this software without specific prior written permission.
		
		THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR
		IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND
		FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR
		CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
		DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
		DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER
		IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT
		OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
	#tag EndNote


	#tag Property, Flags = &h1
		Protected argv() As string
	#tag EndProperty

	#tag Property, Flags = &h21
		Private endparse As boolean
	#tag EndProperty

	#tag Property, Flags = &h1
		Protected first_nonopt As integer
	#tag EndProperty

	#tag Property, Flags = &h1
		Protected last_nonopt As integer
	#tag EndProperty

	#tag Property, Flags = &h1
		Protected longind As integer
	#tag EndProperty

	#tag Property, Flags = &h1
		Protected longopt_handled As boolean
	#tag EndProperty

	#tag Property, Flags = &h1
		Protected long_only As boolean
	#tag EndProperty

	#tag Property, Flags = &h1
		Protected long_options() As RBLongOpt
	#tag EndProperty

	#tag Property, Flags = &h1
		Protected nextchar As string
	#tag EndProperty

	#tag Property, Flags = &h1
		Protected optarg As string
	#tag EndProperty

	#tag Property, Flags = &h1
		Protected opterr As boolean
	#tag EndProperty

	#tag Property, Flags = &h1
		Protected optind As integer
	#tag EndProperty

	#tag Property, Flags = &h1
		Protected optopt As integer
	#tag EndProperty

	#tag Property, Flags = &h1
		Protected optstring As string
	#tag EndProperty

	#tag Property, Flags = &h1
		Protected ordering As integer
	#tag EndProperty

	#tag Property, Flags = &h1
		Protected posixly_correct As boolean
	#tag EndProperty

	#tag Property, Flags = &h1
		Protected progname As string
	#tag EndProperty


	#tag Constant, Name = kErrorAmbiguous, Type = String, Dynamic = False, Default = \"{0}: option \'{1}\' is ambiguous", Scope = Protected
	#tag EndConstant

	#tag Constant, Name = kErrorArguments1, Type = String, Dynamic = False, Default = \"{0}: option \'--{1}\' doesn\'t allow an argument", Scope = Protected
	#tag EndConstant

	#tag Constant, Name = kErrorArguments2, Type = String, Dynamic = False, Default = \"{0}: option \'{1}{2}\' doesn\'t allow an argument", Scope = Protected
	#tag EndConstant

	#tag Constant, Name = kErrorIllegal, Type = String, Dynamic = False, Default = \"{0}: illegal option -- {1}", Scope = Protected
	#tag EndConstant

	#tag Constant, Name = kErrorInvalid, Type = String, Dynamic = False, Default = \"{0}: invalid option -- {1}", Scope = Protected
	#tag EndConstant

	#tag Constant, Name = kErrorRequires1, Type = String, Dynamic = False, Default = \"{0}: option \'{1}\' requires an argument", Scope = Protected
	#tag EndConstant

	#tag Constant, Name = kErrorRequires2, Type = String, Dynamic = False, Default = \"{0}: option requires an argument -- {1}", Scope = Protected
	#tag EndConstant

	#tag Constant, Name = kErrorUnrecognized1, Type = String, Dynamic = False, Default = \"{0}: unrecognized option \'--{1}\'", Scope = Protected
	#tag EndConstant

	#tag Constant, Name = kErrorUnrecognized2, Type = String, Dynamic = False, Default = \"{0}: unrecognized option \'{1}{2}\'", Scope = Protected
	#tag EndConstant

	#tag Constant, Name = PERMUTE, Type = Integer, Dynamic = False, Default = \"2", Scope = Protected
	#tag EndConstant

	#tag Constant, Name = REQUIRE_ORDER, Type = Integer, Dynamic = False, Default = \"1", Scope = Protected
	#tag EndConstant

	#tag Constant, Name = RETURN_IN_ORDER, Type = Integer, Dynamic = False, Default = \"3", Scope = Protected
	#tag EndConstant


	#tag ViewBehavior
		#tag ViewProperty
			Name="Index"
			Visible=true
			Group="ID"
			InitialValue="-2147483648"
			InheritedFrom="Object"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Left"
			Visible=true
			Group="Position"
			InitialValue="0"
			InheritedFrom="Object"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Name"
			Visible=true
			Group="ID"
			InheritedFrom="Object"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Super"
			Visible=true
			Group="ID"
			InheritedFrom="Object"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Top"
			Visible=true
			Group="Position"
			InitialValue="0"
			InheritedFrom="Object"
		#tag EndViewProperty
	#tag EndViewBehavior
End Class
#tag EndClass
