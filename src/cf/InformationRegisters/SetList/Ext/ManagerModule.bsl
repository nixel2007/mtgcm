Procedure UpdateData() Export
	
	SetListData = MTGJSON.GetMTGData("SetList.json");
		
	For Each Set In SetListData Do
		
		RecordManager = InformationRegisters.SetList.CreateRecordManager();
		RecordManager.SetCode 		= Set.Get("code");
		RecordManager.SetName 		= Set.Get("name");		
		RecordManager.ReleaseDate 	= MTGJSON.GetParameterAs1CDate(Set, "releaseDate");
		
		RecordManager.Write();
	
	EndDo; // Each Set In SetListData
	
EndProcedure