Function UpdateData(GetExtra = False) Export
		
	ExtraSuffix = ?(GetExtra, "-x", "");
	
	// Set data
	SetName = ThisObject.Code + ExtraSuffix + ".json";
	SetData = MTGJSON.GetMTGData(SetName);
	
	BeginTransaction();
	
	ThisObject.Description 	= SetData.Get("name");
	
	gathererCodeString = SetData.Get("gathererCode");
	If NOT gathererCodeString = Undefined Then
		ThisObject.GathererCode = Number(gathererCodeString);
	EndIf;
	
	oldCodeString = SetData.Get("oldCode");
	If NOT oldCodeString = Undefined Then
		ThisObject.OldCode = Number(oldCodeString);
	EndIf;

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
	
	BoosterRecordSet = РегистрыСведений.SetBoosterComposition.СоздатьНаборЗаписей();
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
	
	// Cards data
	
	CommitTransaction();
	
EndFunction