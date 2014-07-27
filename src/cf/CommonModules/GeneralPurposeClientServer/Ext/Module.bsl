// Дополняет массив МассивПриемник значениями из массива МассивИсточник.
//
// Параметры:
//  МассивПриемник - Массив - массив, в который необходимо добавить значения.
//  МассивИсточник - Массив - массив значений для заполнения,
//	ТолькоУникальныеЗначения - булево, необязательный, если истина, 
//		то в массив будут включены только те значения, которых в нем еще нет, причем единожды
// 
Процедура CompleteArray(МассивПриемник, МассивИсточник, ТолькоУникальныеЗначения = Ложь) Экспорт

	УникальныеЗначения = Новый Соответствие;
	
	Если ТолькоУникальныеЗначения Тогда
		Для каждого Значение Из МассивПриемник Цикл
			УникальныеЗначения.Вставить(Значение, Истина);
		КонецЦикла;
	КонецЕсли;
	
	Для каждого Значение Из МассивИсточник Цикл
		Если ТолькоУникальныеЗначения И УникальныеЗначения[Значение] <> Неопределено Тогда
			Продолжить;
		КонецЕсли;
		МассивПриемник.Добавить(Значение);
		УникальныеЗначения.Вставить(Значение, Истина);
	КонецЦикла;
	
КонецПроцедуры

// Compare two version strings.
//
// Parameters
//  VersionString1  – String – version number like MM.{m|mm}.RR.BB
//  VersionString2  – String – the second version number
//
// Return value:
//   Number   – greater 0, if VersionString1 > VersionString2; 0, if versions are equal.
Function CompareVersions(Val VersionString1, Val VersionString2) Export
	
	String1 = ?(IsBlankString(VersionString1), "0.0.0.0", VersionString1);
	String2 = ?(IsBlankString(VersionString2), "0.0.0.0", VersionString2);
	
	StringFunctionsClientServer.AdduceToUniformVersionFormat(String1, String2);
	
	Version1 = StringFunctionsClientServer.DecomposeStringToArrayOfSubstrings(String1, ".");
	Version2 = StringFunctionsClientServer.DecomposeStringToArrayOfSubstrings(String2, ".");
		
	Result = 0;
	For Digit = 0 To Version1.UBound() Do
		Result = Number(Version1[Digit]) - Number(Version2[Digit]);
		If Result <> 0 Then
			Return Result;
		EndIf; // Result <> 0
	EndDo; // Digit = 0 To Version1.UBound()
	Return Result;
	
КонецФункции