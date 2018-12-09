#Если Сервер ИЛИ ТолстыйКлиентОбычноеПриложение ИЛИ ВнешнееСоединение Тогда

#Область ОписаниеПеременных

Перем СписокОтчетов;
Перем ДанныеРасшифровкиОтчета Экспорт; // Служебные данные расшифровки

#КонецОбласти

#Область ОбработчикиСобытий

// Обработчик нажатия кнопки "В особенности".
//
Процедура ОтметитьКакОсобенность(ТаблицаОтчета) Экспорт
	
	НомераКОбработке = ОпределитьНомераВыделенныхОшибок(ТаблицаОтчета);
	
	Для Каждого НомерОшибки Из НомераКОбработке Цикл
		
		ЗапросПоСвойствам = Новый Запрос;
		ЗапросПоСвойствам.Текст = "
		|ВЫБРАТЬ
		|	НайденныеОшибки.Объект,
		|	НайденныеОшибки.Правило,
		|	НайденныеОшибки.Номер
		|ИЗ
		|	РегистрСведений.НайденныеОшибки КАК НайденныеОшибки
		|ГДЕ
		|	НайденныеОшибки.Номер = &Номер";
		ЗапросПоСвойствам.УстановитьПараметр("Номер", НомерОшибки);
		
		ВыборкаСвойств = ЗапросПоСвойствам.Выполнить().Выбрать();
		Если ВыборкаСвойств.Следующий() Тогда
			МенеджерОшибки = РегистрыСведений.НайденныеОшибки.СоздатьМенеджерЗаписи();
			МенеджерОшибки.Номер = НомерОшибки;
			МенеджерОшибки.Правило = ВыборкаСвойств.Правило;
			МенеджерОшибки.Объект = ВыборкаСвойств.Объект;
			МенеджерОшибки.Прочитать();
			
			МенеджерОшибки.Состояние = Перечисления.СостояниеОшибки.Особенность;
			МенеджерОшибки.Записать();
		КонецЕсли;
		
	КонецЦикла;
	
КонецПроцедуры

// Обработчик нажатия кнопки "Открыть правило".
//
Процедура ОткрытьПравило(ТаблицаОтчета) Экспорт
	
	НомераКОбработке = ОпределитьНомераВыделенныхОшибок(ТаблицаОтчета);
	
	Если НомераКОбработке.Количество() > 0 Тогда
		// Есть определены номера ошибок - можем выполнить действия над конкретной ошибкой.
		
		ЗапросПоПравилам = Новый Запрос;
		ЗапросПоПравилам.Текст = "
		|ВЫБРАТЬ РАЗЛИЧНЫЕ
		|	НайденныеОшибки.Правило
		|ИЗ
		|	РегистрСведений.НайденныеОшибки КАК НайденныеОшибки
		|ГДЕ
		|	НайденныеОшибки.Номер В(&СписокНомеров)";
		
		ЗапросПоПравилам.УстановитьПараметр("СписокНомеров", НомераКОбработке);
		ВыборкаПравил = ЗапросПоПравилам.Выполнить().Выбрать();
		
		Пока ВыборкаПравил.Следующий() Цикл
			ВыборкаПравил.Правило.ПолучитьОбъект().ПолучитьФорму().Открыть();
		КонецЦикла;
		
	КонецЕсли;
	
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

// Функция анализирует выбранные строки в табличном документе
// и находит номера ошибок, присутствующие в этих строках.
// Номера записываются в массив и возвращаются.
//
Функция ОпределитьНомераВыделенныхОшибок(ТаблицаОтчета)
	
	ВсегоКолонок = ТаблицаОтчета.ШиринаТаблицы;
	НомераКОбработке = Новый Массив;
	
	СтрокиОшибок = ТаблицаОтчета.ВыделенныеОбласти;
	Для Каждого СтрокаОшибки Из СтрокиОшибок Цикл
		// Получаем полную расшифровку строки.
		Начало = СтрокаОшибки.Верх;
		Окончание = СтрокаОшибки.Низ;
		
		Для СчетчикСтроки = Начало По Окончание Цикл
			Для СчетчикКолонки = 1 По ВсегоКолонок Цикл
				ОбластьПробы = ТаблицаОтчета.Область(СчетчикСтроки, СчетчикКолонки, СчетчикСтроки, СчетчикКолонки);
				
				Попытка
					ИДРасшифровки = Число(ОбластьПробы.Расшифровка);
				Исключение
					Продолжить;
				КонецПопытки;
				
				ЭлементРасшифровки = ДанныеРасшифровкиОтчета.Элементы[ИДРасшифровки];
				Попытка
					Если СтрСравнить(ЭлементРасшифровки.ПолучитьПоля()[0].Поле, "Номер") = 0 Тогда
						НомераКОбработке.Добавить(ЭлементРасшифровки.ПолучитьПоля()[0].Значение);
						Прервать;
					КонецЕсли;
				Исключение
				КонецПопытки;
				
			КонецЦикла;
		КонецЦикла;
		
	КонецЦикла;
	
	Возврат НомераКОбработке;
	
КонецФункции

// Возвращает список доступных для формирования отчетов в данном отчете.
//
Функция ПолучитьСписокОтчетов() Экспорт
	
	Если СписокОтчетов = Неопределено Тогда
		СписокОтчетов = Новый СписокЗначений;
		Для Каждого Макет Из Метаданные().Макеты Цикл
			СписокОтчетов.Добавить(Макет.Имя, Макет.Синоним);
		КонецЦикла;
	КонецЕсли;
	
	Возврат СписокОтчетов;
	
КонецФункции

// Возвращает результаты отчета в виде табличного документа.
//
Функция СформироватьТабличныйДокумент(ИмяОтчета, ПараметрыНастроек, Настройки = Неопределено) Экспорт
	
	// Получаем СКД.
	Схема = ПолучитьМакет(ИмяОтчета);
	
	Для Каждого ЗначениеПараметра Из Схема.Параметры Цикл
		ЗначениеКУстановке = ПараметрыНастроек[ЗначениеПараметра.Имя];
		Если ЗначениеКУстановке <> Неопределено Тогда
			ЗначениеПараметра.Значение = ЗначениеКУстановке;
		КонецЕсли;
	КонецЦикла;
	
	// Получаем настройки по умолчанию.
	Если Настройки = Неопределено Тогда
		Настройки = Схема.НастройкиПоУмолчанию;
	КонецЕсли;
	
	// Создаем компоновщик.
	Компоновщик = Новый КомпоновщикМакетаКомпоновкиДанных;
	МакетКомпоновки = Компоновщик.Выполнить(Схема, Настройки, ДанныеРасшифровкиОтчета);
	
	// Создаем процессор компоновки.
	Процессор = Новый ПроцессорКомпоновкиДанных;
	Процессор.Инициализировать(МакетКомпоновки,, ДанныеРасшифровкиОтчета, Истина);
	
	// Формируем табличный документ.
	ТабДокумент = Новый ТабличныйДокумент;
	ПроцессорВывода = Новый ПроцессорВыводаРезультатаКомпоновкиДанныхВТабличныйДокумент;
	
	ПроцессорВывода.УстановитьДокумент(ТабДокумент);
	
	ПроцессорВывода.Вывести(Процессор, Истина);
	
	Возврат ТабДокумент;
	
КонецФункции

#КонецОбласти

#Область Инициализация

СписокОтчетов = Неопределено;

#КонецОбласти

#КонецЕсли