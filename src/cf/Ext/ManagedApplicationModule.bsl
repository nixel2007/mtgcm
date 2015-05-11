Procedure OnStart()
	
	If MTGJSON.UpdateAvailable() Then

		ShowQueryBox(
			New NotifyDescription("UpdateAllMTGDataEnding", GeneralPurposeClient),
			"Do you want to update the card database?",
			QuestionDialogMode.YesNo,
			15,
			,
			"Update is available!"
		);
								
	EndIf;
	
EndProcedure
