#Если Сервер ИЛИ ТолстыйКлиентОбычноеПриложение ИЛИ ВнешнееСоединение Тогда

#Область СлужебныеПроцедурыИФункции

// Загружает содержание дополнения из указанного файла.
//
Процедура ЗагрузитьСодержание(ИФСодержания) Экспорт
	
	Попытка
		Содержание = Новый ХранилищеЗначения(Новый ДвоичныеДанные(ИФСодержания));
	Исключение
		Содержание = Неопределено;
	КонецПопытки;
	
КонецПроцедуры

#КонецОбласти

#КонецЕсли
