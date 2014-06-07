Procedure UpdateSets() Export
		
	SetListData = MTGJSON.GetMTGData("SetList.json");
	
	For Each Set In SetListData Do
		Message("" + Set.Get("code") + ": " + Set.Get("name"));		
	EndDo;
	
EndProcedure

Function DataBaseURL()
	
	Return "http://mtgjson.com/json/";

EndFunction