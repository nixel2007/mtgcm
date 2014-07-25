
&НаКлиенте
Процедура ОбработкаКоманды(ПараметрКоманды, ПараметрыВыполненияКоманды)

	UpdateCardImagesAtServer(ПараметрКоманды);
	
КонецПроцедуры

&AtServer
Procedure UpdateCardImagesAtServer(Set)
	
	BeginTransaction();
	
	// ToDo
	// Временный костыль. Проблемы с методом Выбрать() из РезультатЗапроса
	
	//Query = New Query;
	//Query.Text =
	//"SELECT
	//|	Cards.Ref,
	//|	Cards.Code
	//|FROM
	//|	Catalog.Cards As Cards
	//|WHERE
	//|	Cards.Owner = &Owner";
	//
	//Query.SetParameter("Owner", Set);
	//QueryResult = Query.Execute();
	//
	//If QueryResult.IsEmpty() Then
	//	Return;
	//EndIf; // QueryResult.IsEmpty()
	//
	//QueryResultSelection = QueryResult.Select();
	
	QueryResultSelection = Справочники.Cards.Выбрать(, Set);
	
	While QueryResultSelection.Next() Do
		
		CardImageData = MTGImage.GetMTGData(QueryResultSelection.Code);
		
		CardImagesRecordManager = InformationRegisters.CardImages.CreateRecordManager();
		CardImagesRecordManager.Card 	= QueryResultSelection.Ref;
		CardImagesRecordManager.Image 	= New ValueStorage(CardImageData, New Deflation(9));
	
		CardImagesRecordManager.Write();
		
	EndDo; // QueryResultSelection.Next()
	
	CommitTransaction();
	
EndProcedure
