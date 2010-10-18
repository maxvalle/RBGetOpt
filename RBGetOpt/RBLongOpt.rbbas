#tag Class
Protected Class RBLongOpt
	#tag Method, Flags = &h0
		Sub Constructor(in_name as string, in_has_arg as integer, in_flag as memoryBlock, in_value as integer)
		  
		  // Create a new RBLongOpt object with the given parameter values.  If the
		  // value passed as has_arg is not valid, then an exception is thrown.
		  
		  // Validate has_arg
		  if in_has_arg <> NO_ARGUMENT and in_has_arg <> REQUIRED_ARGUMENT _
		    and in_has_arg <> OPTIONAL_ARGUMENT then
		    raise new IllegalArgumentException(Replace(kErrorInvalidValue, "{0}", str(in_has_arg)))
		  end if
		  
		  // Store off values
		  me.name = in_name
		  me.has_arg = in_has_arg
		  me.flag = in_flag
		  me.value = in_value
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function getFlag() As memoryBlock
		  return me.flag
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function getHasArg() As Integer
		  return me.has_arg
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function getName() As String
		  return me.name
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function getVal() As Integer
		  return me.value
		End Function
	#tag EndMethod


	#tag Property, Flags = &h1
		Protected flag As memoryBlock
	#tag EndProperty

	#tag Property, Flags = &h1
		Protected has_arg As integer
	#tag EndProperty

	#tag Property, Flags = &h1
		Protected name As string
	#tag EndProperty

	#tag Property, Flags = &h1
		Protected value As integer
	#tag EndProperty


	#tag Constant, Name = kErrorInvalidValue, Type = String, Dynamic = False, Default = \"Invalid value {0} for parameter \'has_arg\'", Scope = Protected
	#tag EndConstant

	#tag Constant, Name = NO_ARGUMENT, Type = Integer, Dynamic = False, Default = \"0", Scope = Public
	#tag EndConstant

	#tag Constant, Name = OPTIONAL_ARGUMENT, Type = Integer, Dynamic = False, Default = \"2", Scope = Public
	#tag EndConstant

	#tag Constant, Name = REQUIRED_ARGUMENT, Type = Integer, Dynamic = False, Default = \"1", Scope = Public
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
