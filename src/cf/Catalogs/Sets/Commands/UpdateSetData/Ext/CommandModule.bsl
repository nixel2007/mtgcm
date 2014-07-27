
&НаКлиенте
Процедура ОбработкаКоманды(ПараметрКоманды, ПараметрыВыполненияКоманды)
	
	UpdateSetDataAtServer(ПараметрКоманды);	
	
КонецПроцедуры

&AtServer
Procedure UpdateSetDataAtServer(SetRef)
	
	SetObject = SetRef.GetObject();
	SetObject.UpdateData();
	
EndProcedure