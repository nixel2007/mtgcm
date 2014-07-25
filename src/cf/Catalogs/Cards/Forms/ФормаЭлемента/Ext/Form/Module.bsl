
&НаСервере
Процедура UpdateCardImageНаСервере()
	
	CardImageData = MTGImage.GetMTGData(Object.Code);
	
	CardImagesRecordManager = InformationRegisters.CardImages.CreateRecordManager();
	CardImagesRecordManager.Card 	= Object.Ref;
	CardImagesRecordManager.Image 	= New ValueStorage(CardImageData, New Deflation(9));
	
	CardImagesRecordManager.Write();
	
	PutToTempStorage(CardImageData, CardImage);
		
КонецПроцедуры

&НаКлиенте
Процедура UpdateCardImage(Команда)
	
	If Object.Ref.IsEmpty() Then
		Write();
	EndIf;
	
	UpdateCardImageНаСервере();
	
	Items.CardImage.Refresh();
	
КонецПроцедуры

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	
	If Object.Ref.IsEmpty() Then
		CardImageData = Undefined;
	Else
		CardImagesRecordManager = InformationRegisters.CardImages.CreateRecordManager();
		CardImagesRecordManager.Card = Object.Ref;
		
		CardImagesRecordManager.Read();
		
		If CardImagesRecordManager.Selected() Then
			CardImageData = CardImagesRecordManager.Image.Get();
		Else
			CardImageData = Undefined;
		EndIf;
	EndIf;
	
	CardImage = PutToTempStorage(CardImageData, ThisForm.UUID); 
	
КонецПроцедуры

&НаКлиенте
Процедура VariationsVariationIdОткрытие(Элемент, СтандартнаяОбработка)
	
	СтандартнаяОбработка = False;
	
	CurrentData = Items.Variations.CurrentData;
	
	If CurrentData = Undefined Then
		Return;
	EndIf;
	
	CardId = CurrentData.VariationId; 
	Ref = GetCardRefById(CardId);
	
	If Ref = Undefined Then
		UserMessage = New UserMessage;
		UserMessage.Text = "Couldn't find card with ID: " + CardId;
		
		UserMessage.Message();
	Else
		FormParameters = New Structure;
		FormParameters.Insert("Key", Ref);
		OpenForm("Catalog.Cards.ФормаОбъекта", FormParameters, ThisForm);
	EndIf;
	
КонецПроцедуры

&НаСервереБезКонтекста
Function GetCardRefById(CardId)
	
	Запрос = Новый Запрос;
	
	Запрос.Текст =
	"ВЫБРАТЬ
	|	Cards.Ссылка КАК Ref
	|ИЗ
	|	Справочник.Cards КАК Cards
	|ГДЕ
	|	Cards.Код = &Id";
	
	Запрос.УстановитьПараметр("Id", CardId);
	
	Результат = Запрос.Выполнить();
	
	Если Результат.Пустой() Тогда
		Возврат Неопределено;
	Иначе
		Выборка = Результат.Выбрать();
		Выборка.Следующий();
		Возврат Выборка.Ref;
	КонецЕсли;
	
EndFunction
