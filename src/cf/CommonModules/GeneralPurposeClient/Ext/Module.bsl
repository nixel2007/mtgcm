Procedure UpdateAllMTGDataEnding(QuestionResult, AdditionalParameters) Export
	
	Answer = QuestionResult;
	If Answer = DialogReturnCode.Yes Then
		MTGJSON.UpdateAllData();
	EndIf;
	
EndProcedure
