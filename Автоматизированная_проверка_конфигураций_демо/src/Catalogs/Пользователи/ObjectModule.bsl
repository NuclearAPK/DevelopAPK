#Если Сервер ИЛИ ТолстыйКлиентОбычноеПриложение ИЛИ ВнешнееСоединение Тогда

#Область ОбработчикиСобытий

Процедура ПередЗаписью(Отказ)
	
	Если ОбменДанными.Загрузка Тогда
		Возврат;
	КонецЕсли;
	
	Если НЕ ЗначениеЗаполнено(Код) Тогда
		Код = Наименование;
	КонецЕсли;
	
	Если ЗначениеЗаполнено(ПользовательОС) Тогда
		ПользовательОС = НРег(ПользовательОС);
	КонецЕсли;
	
КонецПроцедуры

#КонецОбласти

#КонецЕсли