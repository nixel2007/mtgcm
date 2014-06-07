Function EnumValueBySynonym(EnumType, EnumSynonym) Export
	
	UpperSynonym = Upper(EnumSynonym);
	
	EnumValues = Metadata.Enums[EnumType].EnumValues;
	
	For Each EnumValue In EnumValues Do
		
		If UpperSynonym = Upper(EnumValue.Synonym) Then
			
			Result = Enums[EnumType][EnumValue.Name];			
			Return Result;
		EndIf;
		
	EndDo;
	
	Raise "Can't find enum value by synonym. Type: " + EnumType + ", Synonym: " + EnumSynonym;	
		
EndFunction
