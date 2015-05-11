
Procedure PresentationGetProcessing(Data, Presentation, StandartProcessing)
	
	Ref = Undefined;
	If NOT Data.Свойство("Ref", Ref) Then
		Return;
	EndIf;
	
	CardLanguage = GeneralPuproseRepUse.GetCardLanguage();
	
	If NOT ValueIsFilled(CardLanguage) Then
		Return;
	EndIf;
	
	ForeignNameString = Ref.ForeignNames.Find(CardLanguage, "Language");
	
	If NOT ValueIsFilled(ForeignNameString) Then
		Return;
	EndIf;
	
	StandartProcessing = False;
	
	Presentation = ForeignNameString.Name + " (" + Ref.Description + ")";
	
EndProcedure
