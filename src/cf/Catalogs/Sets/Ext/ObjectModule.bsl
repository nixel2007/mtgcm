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
		
		cmcString = CardData.Get("cmc");
		If NOT cmcString = Undefined Then
			Card.CMC = Number(cmcString);
		EndIf;
		
		powerString = CardData.Get("power");
		If NOT powerString = Undefined Then
			Card.Power = Number(powerString);
		EndIf;
		
		toughnessString = CardData.Get("toughness");
		If NOT toughnessString = Undefined Then
			Card.Toughness = Number(toughnessString);
		EndIf;
		
		numberString = CardData.Get("number");
		If NOT numberString = Undefined Then
			Card.Number = Number(numberString);
		EndIf;
		
		loyaltyString = CardData.Get("loyalty");
		If NOT loyaltyString = Undefined Then
			Card.Loyalty = Number(loyaltyString);
		EndIf;
				
		CardDataTypes = CardData.Get("types");
		Card.Types.Clear();
		For Each CardDataType In CardDataTypes Do
			LineCardTypes = Card.Types.Add();
			LineCardTypes.Type = CardDataType;
		EndDo; // Each CardType In CardDataTypes
		
		CardDataSubTypes = CardData.Get("subtypes");
		If NOT CardDataSubTypes = Undefined Then
			Card.SubTypes.Clear();
			For Each CardDataSubType In CardDataSubTypes Do
				LineCardSubTypes = Card.SubTypes.Add();
				LineCardSubTypes.SubType = CardDataSubType;
			EndDo; // Each CardSubType In CardDataSubTypes
		EndIf; // NOT CardDataSubTypes = Undefined
		
		CardDataColors = CardData.Get("colors");
		If NOT CardDataColors = Undefined Then
			Card.Colors.Clear();
			For Each CardDataColor In CardDataColors Do
				LineCardColors = Card.Colors.Add();
				LineCardColors.Color = CardDataColor;
			EndDo; // Each CardDataColor In CardDataColors
		EndIf; // NOT CardDataColors = Undefined
		
		Card.Write();
		
	EndDo;
	
	CommitTransaction();
	
EndFunction