Function GetMTGData(FileAddress) Export
	
	DataURL = DataBaseURL() + FileAddress;	
	DataTempFile = GetTempFileName("json");
	
	FileCopy(DataURL, DataTempFile);
	
	DataReader = New TextReader(DataTempFile);
	DataText = DataReader.Read();
	
	Data = JSON.ReadJSON(DataText);	
	
	Return Data;
	
EndFunction
		
Function DataBaseURL()
	
	Return "http://mtgjson.com/json/";

EndFunction	