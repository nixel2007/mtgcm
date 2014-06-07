
Процедура ПередЗаписью(Отказ)
	
	If ThisObject.Names.Count() = 0 Then
		Return;
	EndIf;
	
	ThisObject.Description = "";
	
	For Each Line In ThisObject.Names Do
		ThisObject.Description = ThisObject.Description + Line.Name + " / ";			
	EndDo;
	
	ThisObject.Description = Left(ThisObject.Description, СтрДлина(ThisObject.Description) - 3);
	
КонецПроцедуры
