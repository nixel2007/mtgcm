﻿
&НаКлиенте
Процедура ПолучитьСписокСетов(Команда)
	
	ПолучитьСписокСетовНаСервере();
	
КонецПроцедуры

&НаСервере
Процедура ПолучитьСписокСетовНаСервере()
	
	InformationRegisters.SetList.UpdateData();
	
	ОбновитьСписокВыбораСетов();

КонецПроцедуры

&НаСервереБезКонтекста
Процедура ЗагрузитьВыбранныйСет(ВыбранныйСет, GetExtra)
	
	Set = Справочники.Sets.НайтиПоКоду(ВыбранныйСет, Истина);
	
	If Set.IsEmpty() Then
		Set = Справочники.Sets.СоздатьЭлемент();
		Set.Code = ВыбранныйСет;
		Set.Description = "temp";
		Set.Write();
	Else
		Set = Set.GetObject();
	EndIf;
	
	Set.UpdateData(GetExtra);
	
КонецПроцедуры

&НаКлиенте
Процедура ЗагрузитьВыбранныеСеты(Команда)
	
	ВыбранныеСеты = Новый Массив;
	
	Если РежимЗагрузки = 0 Тогда		
		ВыбранныеСеты.Добавить(ВыбранныйСет);
	Иначе
		Для Каждого ЭлементСписокСетов Из СписокСетов Цикл
			Если ЭлементСписокСетов.Пометка Тогда
				ВыбранныеСеты.Добавить(ЭлементСписокСетов.Значение);
			КонецЕсли;
		КонецЦикла;
	КонецЕсли;
	
	ЗагрузитьВыбранныеСетыНаСервере(ВыбранныеСеты, GetExtra);
	
	ОповеститьОбИзменении(Тип("СправочникСсылка.Cards"));
	ОповеститьОбИзменении(Тип("СправочникСсылка.Sets"));
	ОповеститьОбИзменении(Тип("РегистрСведенийКлючЗаписи.SetBoosterComposition"));

КонецПроцедуры

&НаСервереБезКонтекста
Процедура ЗагрузитьВыбранныеСетыНаСервере(Знач ВыбранныеСеты, GetExtra)
	
	НачатьТранзакцию();
	
	Для Каждого Сет Из ВыбранныеСеты Цикл
		ЗагрузитьВыбранныйСет(Сет, GetExtra);
	КонецЦикла;
	
	ЗафиксироватьТранзакцию();
	
КонецПроцедуры
	
&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	
	ОбновитьСписокВыбораСетов();
	УправлениеФормой();
	
КонецПроцедуры

&НаСервере
Процедура ОбновитьСписокВыбораСетов()
	
	ВыбранныйСет = "";
	Элементы.ВыбранныйСет.СписокВыбора.Очистить();
	СписокСетов.Очистить();
	
	Запрос = Новый Запрос;
	Запрос.Текст =
	"ВЫБРАТЬ
	|	SetList.SetCode,
	|	SetList.SetName,
	|	SetList.ReleaseDate КАК ReleaseDate
	|ИЗ
	|	РегистрСведений.SetList КАК SetList
	|
	|УПОРЯДОЧИТЬ ПО
	|	ReleaseDate УБЫВ";
	
	Результат = Запрос.Выполнить();
	Если Результат.Пустой() Тогда
		Возврат;
	КонецЕсли;
	
	Выборка = Результат.Выбрать();
	
	Пока Выборка.Следующий() Цикл
		ПредставлениеСета = Выборка.SetCode + " - " + Выборка.SetName + " (" + Формат(Выборка.ReleaseDate, "ДЛФ=D") + ")";
		Элементы.ВыбранныйСет.СписокВыбора.Добавить(Выборка.SetCode, ПредставлениеСета);	
		СписокСетов.Добавить(Выборка.SetCode, ПредставлениеСета);
	КонецЦикла;
	
КонецПроцедуры // ОбновитьСписокВыбораСетов()

&НаКлиенте
Процедура РежимЗагрузкиПриИзменении(Элемент)
	УправлениеФормой();
КонецПроцедуры

&НаСервере
Процедура УправлениеФормой()
	
	Элементы.ВыбранныйСет.Видимость = РежимЗагрузки = 0;
	Элементы.СписокСетов.Видимость = РежимЗагрузки = 1;
	
КонецПроцедуры

