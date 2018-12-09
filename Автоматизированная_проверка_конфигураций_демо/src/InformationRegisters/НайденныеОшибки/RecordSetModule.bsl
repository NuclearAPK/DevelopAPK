#Если Сервер ИЛИ ТолстыйКлиентОбычноеПриложение ИЛИ ВнешнееСоединение Тогда

#Область ОбработчикиСобытий

Процедура ПередЗаписью(Отказ, Замещение)
	
	Если ОбменДанными.Загрузка Тогда
		Возврат;
	КонецЕсли;
	
	// Если текущий набор записей пустой и модифицирован, значит происходит очистка записей по определенному отбору.
	ПризнакУдаленияЗаписи = (Количество() = 0) И Модифицированность();
	Если НЕ ПризнакУдаленияЗаписи Тогда
		Возврат;
	КонецЕсли;
	
	Прочитать();
	
	// Если ошибка удаляется, надо удалить ее комментарий.
	Для Каждого ТекущаяЗапись Из ЭтотОбъект Цикл
		УдалитьКомментарийОшибки(ТекущаяЗапись.Номер);
	КонецЦикла;
	
	Очистить();
	
КонецПроцедуры

Процедура УдалитьКомментарийОшибки(НомерОшибки)
	
	Блокировка = Новый БлокировкаДанных;
	ЭлементБлокировки = Блокировка.Добавить("РегистрСведений.КомментарииНайденныхОшибок");
	ЭлементБлокировки.УстановитьЗначение("Номер", НомерОшибки);
	ЭлементБлокировки.Режим = РежимБлокировкиДанных.Разделяемый;
	
	НачатьТранзакцию();
	
	Попытка
		Блокировка.Заблокировать();
		
		КомментарииНайденныхОшибокНаборЗаписей = РегистрыСведений.КомментарииНайденныхОшибок.СоздатьНаборЗаписей();
		КомментарииНайденныхОшибокНаборЗаписей.Отбор.Номер.Установить(НомерОшибки);
		
		КомментарииНайденныхОшибокНаборЗаписей.Записать();
		
		ЗафиксироватьТранзакцию();
	Исключение
		ОтменитьТранзакцию();
	КонецПопытки;
	
КонецПроцедуры

#КонецОбласти

#КонецЕсли