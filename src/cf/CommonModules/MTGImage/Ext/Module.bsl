Function GetMTGData(Multiverseid, FileSuffix = ".jpg") Export
	
	DataURL = DataBaseURL() + Format(Multiverseid, "NG=") + FileSuffix;	
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
	
	Return "http://mtgimage.com/multiverseid/";

EndFunction	