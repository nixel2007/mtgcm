Function DataBaseURL()
	
	Return "http://mtgjson.com/json/";

EndFunction

Function GetMTGJSONVersion() Export
	
	VersionData = GetMTGData("version-full.json");
	Version = VersionData.Get("version");
	
	Return Version;
	
EndFunction

Function GetMTGData(FileAddress) Export
	
	DataURL = DataBaseURL() + FileAddress;	
	DataTempFile = GetTempFileName("json");
	
	FileCopy(DataURL, DataTempFile);
	
	DataReader = New TextReader(DataTempFile, TextEncoding.UTF8);
	DataText = DataReader.Read();
	
	Data = JSON.myReadJSON(DataText);	
	
	DataReader.Close();
	
	Try
		DeleteFiles(DataTempFile);
	Except
		Raise ErrorDescription(); 	
	EndTry;
	
	Return Data;
	
EndFunction

Function FindSetsBySetNames(Val SetNamesArray)
	
	StringQualifiers = New StringQualifiers(4);
	
	SetNamesVT = Новый ТаблицаЗначений;
	SetNamesVT.Columns.Add("Code", New TypeDescription("String", , StringQualifiers));
	SetNamesVT.Columns.Add("WithExtraData", New TypeDescription("Boolean"));
	
	For Each SetName In SetNamesArray Do
		SetNameString = SetName;
		WithExtraData = False;	
		
		WithExtraDataFind = Find(SetName, "-x");
		If WithExtraDataFind > 0 Then
			SetNameString = Left(SetName, WithExtraDataFind - 1);
			WithExtraData = True;	
		EndIf; // WithExtraData > 0
		
		RowSetNamesVT = SetNamesVT.Добавить();
		RowSetNamesVT.Code 			= SetNameString;
		RowSetNamesVT.WithExtraData = WithExtraData;
		
	EndDo; 
	
	Query = GeneralPurpose.GetQueryWithVT(SetNamesVT, "VTSetNames");
	
	Query.Text = Query.Text +
	"
	|;
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ РАЗЛИЧНЫЕ
	|	Sets.Ссылка
	|ИЗ
	|	Справочник.Sets КАК Sets
	|		ВНУТРЕННЕЕ СОЕДИНЕНИЕ VTSetNames КАК VTSetNames
	|		ПО (VTSetNames.Code = Sets.Код)
	|			И (VTSetNames.WithExtraData = Sets.WithExtraData)";
		
	QueryResult = Query.Execute();
	
	QueryResultSelection = QueryResult.Выбрать();
	
	Return QueryResultSelection;
	
EndFunction

Procedure AddTextToChangeLog(ChangeLog, VersionData)
	
	version = VersionData.Get("version");
	When 	= GetParameterAs1CDate(VersionData, "whenSiteMap");
	Changes = VersionData.Get("changes");
	
	ChangeLog = ChangeLog + version + " (" + Format(When, "ДЛФ=D") + ")" + Chars.LF;
	
	For Each Change In Changes Do
		ChangeLog = ChangeLog + Change + Chars.LF;
	EndDo; // Each Change In Changes
	
EndProcedure

Function UpdateAvailable() Export
	
	Try
		Version	= GetMTGJSONVersion();
	Except
		Message("No internet connection. Can't check for updates.");
		Return False;
	EndTry;
	DBVersion 	= Constants.JSONDBVersion.Get();
	
	Return GeneralPurposeClientServer.CompareVersions(Version, DBVersion) > 0;
		
EndFunction

Procedure UpdateAllData() Export
		
	InformationRegisters.SetList.UpdateData();
	
	ChangeLogData = GetMTGData("changelog.json");
	DBVersion = Constants.JSONDBVersion.Get();
	
	index = ChangeLogData.UBound();
	While index >= 0 Do
		ChangeLogVersion = ChangeLogData[index].Get("version");
		If GeneralPurposeClientServer.CompareVersions(DBVersion, ChangeLogVersion) >= 0 Then
			ChangeLogData.Delete(index);
		EndIf;
		
		index = index - 1;
	EndDo; // index >= 0
	
	UpdatedSets = New Array;
	NewSets 	= New Array;	
	RemovedSets = New Array;
	ChangeLog = "";
	For Each VersionData In ChangeLogData Do
		
		AddTextToChangeLog(ChangeLog, VersionData);
		
		UpdatedSetFiles = VersionData.Get("updatedSetFiles");
		If NOT UpdatedSetFiles = Undefined Then
			GeneralPurposeClientServer.CompleteArray(UpdatedSets, UpdatedSetFiles, True); 	
		EndIf; // NOT UpdatedSetFiles = Undefined
		
		NewSetFiles = VersionData.Get("newSetFiles");
		If NOT NewSetFiles = Undefined Then
			GeneralPurposeClientServer.CompleteArray(NewSets, NewSetFiles, True); 	
		EndIf; // NOT NewSetFiles = Undefined
		
		RemovedSetFiles = VersionData.Get("removedSetFiles");
		If NOT RemovedSetFiles = Undefined Then
			GeneralPurposeClientServer.CompleteArray(RemovedSets, RemovedSetFiles, True); 	
		EndIf; // NOT RemovedSetFiles = Undefined
		
	EndDo; // Each VersionData In ChangeLogData
	
	Message(ChangeLog);
	
	If UpdatedSets.Count() > 0 Then	
		SelectionUpdatedSets = FindSetsBySetNames(UpdatedSets);
		Catalogs.Sets.UpdateData(SelectionUpdatedSets);
	EndIf; // UpdatedSets.Count() > 0
	
	For Each NewSetFile In NewSets Do
		UserMessage = New UserMessage;
		UserMessage.Text = "New set available : " + NewSetFile;
		UserMessage.Message();
	EndDo; // Each NewSetFile In NewSetFiles
	                    
	If RemovedSets.Count() > 0 Then
		SelectionRemovedSets = FindSetsBySetNames(RemovedSets);	
		While SelectionRemovedSets.Next() Do
			RemovedSetObject = SelectionRemovedSets.Ref.GetObject();
			RemovedSetObject.SetDeletionMark(True);
			
			UserMessage = New UserMessage;
			UserMessage.Text = "Set removed: " + RemovedSetObject.Description;
			UserMessage.SetData(RemovedSetObject);
			UserMessage.Message();
		EndDo; // SelectionRemovedSets.Next()
	EndIf; // RemovedSets.Count() > 0
	
	Version	= GetMTGJSONVersion();
	Constants.JSONDBVersion.Set(Version);
	
EndProcedure

Function GetParameterAs1CDate(Map, ParameterName) Export
	
	ParameterString = Map.Get(ParameterName);
	ParameterString = StrReplace(ParameterString, "-", "");	
	ParameterDate  	= Date(ParameterString);
	
	Return ParameterDate;
		
EndFunction