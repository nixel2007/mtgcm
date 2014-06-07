
&НаСервере
Процедура UpdateCardImageНаСервере()
	
	CardImageData = MTGImage.GetMTGData(Object.Multiverseid);
	
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
