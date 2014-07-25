Function UpdateData(GetExtra = False) Export
		
	ExtraSuffix = ?(GetExtra, "-x", "");
	
	// Set data
	SetName = ThisObject.Code + ExtraSuffix + ".json";
	SetData = MTGJSON.GetMTGData(SetName);
	
	BeginTransaction();
	
	ThisObject.Description = SetData.Get("name");
	
	gathererCodeString = SetData.Get("gathererCode");
	If NOT gathererCodeString = Undefined Then
		ThisObject.GathererCode = gathererCodeString;
	EndIf;
	
	oldCodeString = SetData.Get("oldCode");
	If NOT oldCodeString = Undefined Then
		ThisObject.OldCode = oldCodeString;
	EndIf;
	
	ThisObject.OnlineOnly = SetData.Get("onlineOnly");

	releaseDateString = SetData.Get("releaseDate");
	releaseDateString = StrReplace(releaseDateString, "-", "");	
	ThisObject.ReleaseDate 	= Date(releaseDateString);
	
	ThisObject.Block		= SetData.Get("block");
	
	SetTypeString = SetData.Get("type");
	ThisObject.Type = GeneralPurpose.EnumValueBySynonym("SetTypes", SetTypeString);
	
	BorderTypeString = SetData.Get("border");
	ThisObject.Border = GeneralPurpose.EnumValueBySynonym("BorderTypes", BorderTypeString);
	
	ThisObject.Write();
	
	// Booster data
	BoosterData = SetData.Get("booster");
	
	// Not all sets have boosters
	If NOT BoosterData = Undefined Then
		BoosterRecordSet = InformationRegisters.SetBoosterComposition.CreateRecordSet();
		BoosterRecordSet.Filter.Set.Set(ThisObject.Ref);
		
		index = 1;
		
		For Each BoosterPositionData In BoosterData Do
			
			If TypeOf(BoosterPositionData) = Type("Array") Then
				
				For Each BosterCardTypeData In BoosterPositionData Do
					BoosterCard = BoosterRecordSet.Add();
				
					BoosterCard.Set 		= ThisObject.Ref;
					BoosterCard.CardType 	= GeneralPurpose.EnumValueBySynonym("CardTypes", BosterCardTypeData);
					BoosterCard.CardNumber	= index;					
					
				EndDo;
				
			Else
				BoosterCard = BoosterRecordSet.Add();
				
				BoosterCard.Set 		= ThisObject.Ref;
				BoosterCard.CardType 	= GeneralPurpose.EnumValueBySynonym("CardTypes", BoosterPositionData);
				BoosterCard.CardNumber	= index;
			EndIf;
			
			index = index + 1;
			
		EndDo;
		
		BoosterRecordSet.Write();
	EndIf; // NOT BoosterData = Undefined
	
	// Cards data
	CardsData = SetData.Get("cards");
	CardIDs = New ValueTable;
	CardIDs.Колонки.Добавить("Code", New TypeDescription("Number"));
	
	For Each CardData In CardsData Do
		CardIDsLine = CardIDs.Добавить();
		CardIDsLine.Code = Number(CardData.Get("multiverseid"));
	EndDo;
	
	// No &VT in queries on mobile, so...
	Query = New Query;
	
	FirstLine = True;	
	QueryText = "";
	
	CardNumber = 1;
	FieldSynonym = 	
	" AS Code
	|INTO
	|	CardIDs";
	For Each CardData In CardsData Do
		ParameterName = "multiverseid" + Format(CardNumber, "NG=");
		QueryText = QueryText + ?(NOT FirstLine, "UNION ALL", "") + Chars.LF +
		"SELECT" + Chars.LF + 
		"&" + ParameterName + ?(FirstLine, FieldSynonym, "")+ Chars.LF;
		
		MultiverseID = Number(CardData.Get("multiverseid"));
		Query.SetParameter(ParameterName, MultiverseID);
		
		CardNumber = CardNumber + 1;
		FirstLine = False;
	EndDo;
	
	QueryText = QueryText + "
	|INDEX BY
	|	Code
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|SELECT
	|	CardIDs.Code,
	|	Cards.Ref AS Ref
	|FROM
	|	CardIDs AS CardIDs
	|		LEFT JOIN Catalog.Cards AS Cards
	|		ON CardIDs.Code = Cards.Код
	|WHERE
	|	CASE
	|			WHEN Cards.Owner IS NULL 
	|				THEN TRUE
	|			ELSE Cards.Owner = &Set
	|		END";
	
	Query.Text = QueryText;
	
	Query.SetParameter("Set", ThisObject.Ref);
	
	QueryResult = Query.Execute();
	CardRefs = QueryResult.Unload();
	CardRefs.Indexes.Add("Code");
	
	For Each CardData In CardsData Do
		
		MultiverseID = CardData.Get("multiverseid");
		CardRefsLine = CardRefs.Find(MultiverseID, "Code");
		
		If CardRefsLine.Ref = NULL Then
			Card = Catalogs.Cards.CreateItem();
			Card.Code = Number(MultiverseID);
		Else
			Card = CardRefsLine.Ref.GetObject();
		EndIf;
		
		Card.Description 	= CardData.Get("name");
		Card.Owner			= ThisObject.Ref;
		Card.Type 			= CardData.Get("type");
		
		cmcString = CardData.Get("cmc");
		If NOT cmcString = Undefined Then
			Card.CMC = Number(cmcString);
		EndIf;
		
		LayoutTypeString = CardData.Get("layout");
		Card.Layout = GeneralPurpose.EnumValueBySynonym("LayoutTypes", LayoutTypeString);
		
		Card.Write();
		
	EndDo;
	
	CommitTransaction();
	
EndFunction