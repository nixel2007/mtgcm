Function EnumValueBySynonym(EnumType, EnumSynonym) Export
	
	Return GeneralPuproseRepUse.EnumValueBySynonym(EnumType, EnumSynonym);	
		
EndFunction

Function CatalogRefByDescription(EnumType, EnumSynonym) Export
	
	Return GeneralPuproseRepUse.CatalogRefByDescription(EnumType, EnumSynonym);	
		
EndFunction

Function GetQueryWithVT(ValueTable, QueryVTName, Query = Undefined, IndexByNames = "") Export
	
	If Query = Undefined Then
		Query = New Query;
	EndIf; // Query = Undefined
	
	ColumnsVT = ValueTable.Columns;
	
	index = 1;
	FirstRow = True;	
	
	QueryText = "";	
	INTOText = 
	"
	|INTO
	|	" + QueryVTName;
	
	INDEXBYText =
	"
	|INDEX BY 
	|" + IndexByNames + "
	|;";
	
	For Each RowVT In ValueTable Do
		
		FirstColumn = True;
		For Each ColumnVT In ColumnsVT Do
			
			ColumnName = ColumnVT.Name;
			ColumnIndex = ColumnsVT.IndexOf(ColumnVT);
			
			ParameterName = ColumnName + Format(index, "NG=");
			
			If Not FirstRow AND FirstColumn Then
				QueryText = QueryText + Chars.LF + "UNION ALL" + Chars.LF;
			EndIf; // Not FirstRow AND FirstColumn
			
			If FirstColumn Then
				QueryText = QueryText +
							"SELECT" + Chars.LF;
			Else
				QueryText = QueryText + "," + Chars.LF;	
			EndIf; // FirstColumn
			
			QueryText = QueryText +
			"	&" + ParameterName + ?(FirstRow, " AS " + ColumnName, "");
			
			Query.SetParameter(ParameterName, RowVT[ColumnIndex]);
			
			FirstColumn = False;
			
		EndDo; // Each ColumnVT In ColumnsVT
		
		If FirstRow Then
			QueryText = QueryText + INTOText;
		EndIf; // FirstLine
		
		index = index + 1;
		FirstRow = False;
		
	EndDo; // Each RowVT In VT
	
	If ValueIsFilled(IndexByNames) Then
		QueryText = QueryText + INDEXBYText;
	EndIf; // ValueIsFilled(IndexByNames)
	
	Query.Text = Query.Text + QueryText;
	
	Return Query;
	
EndFunction

