
&НаКлиенте
Процедура ОбработкаКоманды(ПараметрКоманды, ПараметрыВыполненияКоманды)

	UpdateCardImagesAtServer(ПараметрКоманды);
	
КонецПроцедуры

&AtServer
Procedure UpdateCardImagesAtServer(Set)
	
	BeginTransaction();
		
	Query = New Query;
	Query.Text =
	"SELECT
	|	Cards.Ref,
	|	Cards.Code
	|FROM
	|	Catalog.Cards As Cards
	|WHERE
	|	Cards.Owner = &Owner";
	
	Query.SetParameter("Owner", Set);
	QueryResult = Query.Execute();
	
	If QueryResult.IsEmpty() Then
		Return;
	EndIf; // QueryResult.IsEmpty()
	
	QueryResultSelection = QueryResult.Выбрать();
		
	While QueryResultSelection.Next() Do
		
		CardImageData = MTGImage.GetMTGData(QueryResultSelection.Code);
		
		CardImagesRecordManager = InformationRegisters.CardImages.CreateRecordManager();
		CardImagesRecordManager.Card 	= QueryResultSelection.Ref;
		CardImagesRecordManager.Image 	= New ValueStorage(CardImageData, New Deflation(9));
	
		CardImagesRecordManager.Write();
		
	EndDo; // QueryResultSelection.Next()
	
	CommitTransaction();
	
EndProcedure
