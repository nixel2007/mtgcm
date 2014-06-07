Function GetMTGData(FileAddress) Export
	
	DataURL = DataBaseURL() + FileAddress;	
	DataTempFile = GetTempFileName("json");
	
	FileCopy(DataURL, DataTempFile);
	
	DataReader = New TextReader(DataTempFile);
	DataText = DataReader.Read();
	
	Data = JSON.ReadJSON(DataText);	
	
	DataReader.Close();
	
	Try
		DeleteFiles(DataTempFile);
	Except
		Raise ErrorDescription(); 	
	EndTry;

	
	Return Data;
	
EndFunction
		
Function DataBaseURL()
	
	Return "http://mtgjson.com/json/";

EndFunction	