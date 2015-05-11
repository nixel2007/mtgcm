Function GetMTGData(Multiverseid) Export
	
	DataURL = DataBaseURL() + Format(Multiverseid, "NG=");	
	DataTempFile = GetTempFileName("jpg");
	
	FileCopy(DataURL, DataTempFile);
	
	Data = New BinaryData(DataTempFile);
	
	Try
		DeleteFiles(DataTempFile);
	Except
		Raise ErrorDescription(); 	
	EndTry;
	
	Return Data;
	
EndFunction
		
Function DataBaseURL()
	
	Return "http://gatherer.wizards.com/Handlers/Image.ashx?type=card&multiverseid=";

EndFunction	