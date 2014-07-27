Procedure UpdateData(SetList = Undefined) Export
	
	If SetList = Undefined Then
		SetList = Catalogs.Sets.Select();
	EndIf; // SetList = Undefined
	
	While SetList.Next() Do
		CatalogObject = SetList.Ref.GetObject();
		CatalogObject.UpdateData();
	EndDo; // SetList.Next()

EndProcedure