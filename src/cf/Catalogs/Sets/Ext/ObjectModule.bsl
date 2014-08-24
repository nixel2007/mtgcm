Function UpdateData(GetExtra = Undefined) Export
	
	If GetExtra = Undefined Then
		GetExtra = ThisObject.WithExtraData;
	EndIf;
	
	ExtraSuffix = ?(GetExtra, "-x", "");
	
	// Set data
	SetName = ThisObject.Code + ExtraSuffix + ".json";
	SetData = MTGJSON.GetMTGData(SetName);
	
	BeginTransaction();
	
	ThisObject.WithExtraData = GetExtra;
	
	ThisObject.Description 	= SetData.Get("name");	
	ThisObject.GathererCode = SetData.Get("gathererCode");
	ThisObject.OldCode 		= SetData.Get("oldCode");
	ThisObject.OnlineOnly 	= SetData.Get("onlineOnly");
	ThisObject.Block		= SetData.Get("block");
	ThisObject.ReleaseDate 	= MTGJSON.GetParameterAs1CDate(SetData, "releaseDate");
	
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
					
				EndDo; // Each BosterCardTypeData In BoosterPositionData
				
			Else
				
				BoosterCard = BoosterRecordSet.Add();
				
				BoosterCard.Set 		= ThisObject.Ref;
				BoosterCard.CardType 	= GeneralPurpose.EnumValueBySynonym("CardTypes", BoosterPositionData);
				BoosterCard.CardNumber	= index;
				
			EndIf; // TypeOf(BoosterPositionData) = Type("Array")
			
			index = index + 1;
			
		EndDo; // Each BoosterPositionData In BoosterData
		
		BoosterRecordSet.Write();
		
	EndIf; // NOT BoosterData = Undefined
	
	// Cards data
	CardsData = SetData.Get("cards");
	CardIDs = New ValueTable;
	CardIDs.Колонки.Добавить("Code", New TypeDescription("Number"));
	
	For Each CardData In CardsData Do
		
		CardIDsLine = CardIDs.Добавить();
		CardIDsLine.Code = Number(CardData.Get("multiverseid"));
		
	EndDo; // Each CardData In CardsData
	
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
		
	EndDo; // Each CardData In CardsData
	
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
		EndIf; // CardRefsLine.Ref = NULL
		
		Card.Owner			= ThisObject.Ref;
		Card.Description 	= CardData.Get("name");
		Card.ImageName		= CardData.Get("imageName");
		Card.Text			= CardData.Get("text");
		Card.Type 			= CardData.Get("type");
		Card.ManaCost 		= CardData.Get("manaCost");
		Card.Artist			= CardData.Get("artist"); 
		Card.Flavor			= CardData.Get("flavor"); 
		
		LayoutTypeString = CardData.Get("layout");
		Card.Layout = GeneralPurpose.EnumValueBySynonym("LayoutTypes", LayoutTypeString);
		
		RarityTypeString = CardData.Get("rarity");
		Card.Rarity = GeneralPurpose.EnumValueBySynonym("CardRarityTypes", RarityTypeString);
		
		FillPropertyIfExist(Card, CardData, "cmc");
		FillPropertyIfExist(Card, CardData, "power");
		FillPropertyIfExist(Card, CardData, "toughness");
		FillPropertyIfExist(Card, CardData, "watermark");
		FillPropertyIfExist(Card, CardData, "timeshifted");				
		FillPropertyIfExist(Card, CardData, "number");
		
		FillPropertyIfExist(Card, CardData, "loyalty", 	True);
						
		CardDataTypes = CardData.Get("types");
		If NOT CardDataTypes = Undefined Then
			Card.Types.Clear();
			For Each CardDataType In CardDataTypes Do
				LineCardTypes = Card.Types.Add();
				LineCardTypes.Type = CardDataType;
			EndDo; // Each CardType In CardDataTypes
		EndIf; // NOT CardDataTypes = Undefined
		
		CardDataSubTypes = CardData.Get("subtypes");
		If NOT CardDataSubTypes = Undefined Then
			Card.SubTypes.Clear();
			For Each CardDataSubType In CardDataSubTypes Do
				LineCardSubTypes = Card.SubTypes.Add();
				LineCardSubTypes.SubType = CardDataSubType;
			EndDo; // Each CardSubType In CardDataSubTypes
		EndIf; // NOT CardDataSubTypes = Undefined
		
		CardDataSuperTypes = CardData.Get("supertypes");
		If NOT CardDataSuperTypes = Undefined Then
			Card.SuperTypes.Clear();
			For Each CardDataSuperType In CardDataSuperTypes Do
				LineCardSuperTypes = Card.SuperTypes.Add();
				LineCardSuperTypes.SuperType = CardDataSuperType;
			EndDo; // Each CardSuperType In CardDataSuperTypes
		EndIf; // NOT CardDataSuperTypes = Undefined
				
		CardDataColors = CardData.Get("colors");
		If NOT CardDataColors = Undefined Then
			Card.Colors.Clear();
			For Each CardDataColor In CardDataColors Do
				LineCardColors = Card.Colors.Add();
				LineCardColors.Color = CardDataColor;
			EndDo; // Each CardDataColor In CardDataColors
		EndIf; // NOT CardDataColors = Undefined
		
		CardDataVariations = CardData.Get("variations");
		If NOT CardDataVariations = Undefined Then
			Card.Variations.Clear();
			For Each CardDataVariation In CardDataVariations Do
				LineCardVariations = Card.Variations.Add();
				LineCardVariations.VariationId = CardDataVariation;
			EndDo; // Each CardVariation In CardDataVariations
		EndIf; // NOT CardDataVariations = Undefined
		
		////////////////
		// ExtraData
		
		If GetExtra Then
			
			FillPropertyIfExist(Card, CardData, "originalType");
			FillPropertyIfExist(Card, CardData, "originalText");
		
			CardDataRulings = CardData.Get("rulings");
			If NOT CardDataRulings = Undefined Then
				Card.Rulings.Clear();
				For Each CardDataRuling In CardDataRulings Do					
					LineCardRulings = Card.Rulings.Add();
					LineCardRulings.Text = CardDataRuling.Get("text");
					LineCardRulings.Date = MTGJSON.GetParameterAs1CDate(CardDataRuling, "date");
				EndDo; // Each CardRuling In CardDataRulings
			EndIf; // NOT CardDataRulings = Undefined		
			
			CardDataforeignNames = CardData.Get("foreignNames");
			If NOT CardDataforeignNames = Undefined Then
				Card.foreignNames.Clear();
				For Each CardDataforeignName In CardDataforeignNames Do						
					LineCardforeignNames = Card.foreignNames.Add();
					LineCardforeignNames.Name 		= CardDataforeignName.Get("name");
					LineCardforeignNames.Language 	= CardDataforeignName.Get("language");					
				EndDo; // Each CardforeignName In CardDataforeignNames
			EndIf; // NOT CardDataforeignNames = Undefined		
			
			CardDataPrintings = CardData.Get("printings");
			If NOT CardDataPrintings = Undefined Then
				Card.Printings.Clear();
				For Each CardDataPrinting In CardDataPrintings Do
					LineCardPrintings = Card.Printings.Add();
					LineCardPrintings.SetName = CardDataPrinting;
				EndDo; // Each CardPrinting In CardDataPrintings
			EndIf; // NOT CardDataPrintings = Undefined
			
			CardDataLegalities = CardData.Get("legalities");
			If NOT CardDataLegalities = Undefined Then
				Card.Legalities.Clear();
				For Each CardDatalegality In CardDataLegalities Do
					LineCardlegalities = Card.Legalities.Add();
					LineCardlegalities.Format = CardDatalegality.Key;
					LineCardlegalities.Status = CardDatalegality.Value;
				EndDo; // Each Cardlegality In CardDataLegalities
			EndIf; // NOT CardDataLegalities = Undefined
		
		EndIf; // GetExtra
		
		// End ExtraData
		////////////////
		
		Card.Write();
		
	EndDo; // Each CardData In CardsData
	
	CommitTransaction();
	
	UserMessage = New UserMessage;
	UserMessage.Text = "Set updated: " + ThisObject.Description;
	UserMessage.SetData(ThisObject);
	UserMessage.Message();
	
EndFunction

Procedure FillPropertyIfExist(Object, PropertyMap, PropertyName, ConvertToNumeric = False)
	
	PropertyValue = PropertyMap.Get(PropertyName);
	If NOT PropertyValue = Undefined Then
		PropertyResult = ?(ConvertToNumeric, Number(PropertyValue), PropertyValue);		
		Object[PropertyName] = PropertyResult;
	EndIf; // NOT PropertyValue = Undefined	
	
EndProcedure