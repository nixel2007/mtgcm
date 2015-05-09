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

Function GetCardLanguage() Export
	
	Return Constants.CardLanguage.Get();
	
EndFunction

Function CatalogRefByDescription(CatalogType, CatalogDescription) Export
	
	UpperSynonym = Upper(CatalogDescription);
	
	CatalogManager = Catalogs[CatalogType];
	CatalogValues = CatalogManager.Select();
	
	While CatalogValues.Next() Do
		
		If UpperSynonym = Upper(CatalogValues.Description) Then
			
			Result = CatalogValues.Ref;			
			Return Result;
		EndIf;
		
	EndDo;
	
	Raise "Can't find catalog ref by synonym. Type: " + CatalogType + ", Synonym: " + CatalogDescription;
	
EndFunction