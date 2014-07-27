
Процедура ПриНачалеРаботыСистемы()
	
	If MTGJSON.UpdateAvailable() Then
		Answer = DoQueryBox("Do you want to update the card database?",
							QuestionDialogMode.YesNo,
							15,
							,
							"Update is available!"
							);
		If Answer = DialogReturnCode.Yes Then
			MTGJSON.UpdateAllData();
		EndIf;
								
	EndIf;
	
КонецПроцедуры
