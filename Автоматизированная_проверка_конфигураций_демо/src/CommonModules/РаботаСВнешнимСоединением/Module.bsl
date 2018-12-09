
#Область СлужебныеПроцедурыИФункции

// Запустить приложения и дождаться завершения вызванного процесса.
//
// Параметры:
//   СтрокаЗапуска - Строка - Строка запуска приложения.
//
// Возвращаемое значение:
//   Структура -
//     * Успешно   - Булево - Флаг успешности запуска приложения.
//     * Сообщение - Строка - Сообщение о запуске приложения.
//
Функция ЗапуститьСОжиданиемЗавершенияРаботыПриложения(СтрокаЗапуска)
	
	Результат = Новый Структура;
	Результат.Вставить("Успешно", Ложь);
	Результат.Вставить("Сообщение", "");
	
	КодВозврата = -1;
	СистемныйПроцесс = Новый COMОбъект("WScript.Shell");
	
	Попытка
		КодВозврата = СистемныйПроцесс.Run(СтрокаЗапуска, 0, Истина);
	Исключение
		Результат.Сообщение = ПодробноеПредставлениеОшибки(ИнформацияОбОшибке());
	КонецПопытки;
	
	Если КодВозврата = 0 Тогда
		Результат.Успешно = Истина;
	Иначе
		ТекстСтрокаЗапуска = СтрШаблон(НСтр("ru='Строка запуска: %1'"), СтрокаЗапуска);
		Результат.Сообщение = СокрЛ(Результат.Сообщение + Символы.ПС + ТекстСтрокаЗапуска);
	КонецЕсли;
	
	Возврат Результат;
	
КонецФункции

// Регистрирует COM-объект "Application" для текущего пользователя.
//
Функция ЗарегистрироватьCOMApplication(СтрокаЗапускаПлатформы)
	
	Результат = Новый Структура;
	Результат.Вставить("Успешно", Ложь);
	Результат.Вставить("Сообщение", "");
	
	ТекстОшибки = НСтр("ru='Ошибка при регистрации COM-объекта Application.'");
	
	Если ПустаяСтрока(СтрокаЗапускаПлатформы) Тогда
		Результат.Сообщение = ТекстОшибки + НСтр("ru='Не указан путь к платформе.'");
		Возврат Результат;
	КонецЕсли;
	
	Если НЕ ФайлСуществует(СтрокаЗапускаПлатформы) Тогда
		Результат.Сообщение = ТекстОшибки + СтрШаблон(НСтр("ru='Не существует указанный путь к платформе:%1%2'"),
			Символы.ПС, СтрокаЗапускаПлатформы);
		Возврат Результат;
	КонецЕсли;
	
	ВерсияПлатформы = ПолучитьВерсиюПлатформыДляЗапуска(СтрокаЗапускаПлатформы);
	Если ПустаяСтрока(ВерсияПлатформы) Тогда
		Результат.Сообщение = НСтр("ru='Не удалось определить номер версии платформы по пути запуска платформы.
			|Текущая версия программы предназначена для проверки конфигураций на платформе не ниже 8.3.6.'");
		Возврат Результат;
	КонецЕсли;
	
	// Начиная с версии платформы 8.3.9, для команды регистрации COM-объекта появился ключ,
	// позволяющий зарегистрировать COM-объект для текущего пользователя.
	Если РелизыПоПорядку(ВерсияПлатформы, "8.3.9.0") Тогда
		// Если версия платформы до 8.3.9, то для пользователя с неполными правами будет вызван модальный вопрос.
		// В таком случае выходим без регистрации COM-объекта.
		Результат.Успешно = Истина;
		Возврат Результат;
	КонецЕсли;
	
	ТекстКоманды = СтрШаблон("""%1"" /RegServer -CurrentUser", СтрокаЗапускаПлатформы);
	
	// Регистрируем COM-объект "Application".
	// Команда "ЗапуститьПриложение" не используется,
	// т.к. по неизвестной причине регистрация COM-объекта срабатывает не всегда.
	Результат = ЗапуститьСОжиданиемЗавершенияРаботыПриложения(ТекстКоманды);
	Если НЕ Результат.Успешно Тогда
		Результат.Сообщение = ТекстОшибки + Символы.ПС + Результат.Сообщение;
	КонецЕсли;
	
	Возврат Результат;
	
КонецФункции

Функция ПолучитьВерсиюCOMСоединения()
	
	СистемнаяИнфо = Новый СистемнаяИнформация;
	ПодстрокиВерсии = СтрРазделить(СистемнаяИнфо.ВерсияПриложения, ".", Ложь);
	
	Возврат "v" + ПодстрокиВерсии[0] + ПодстрокиВерсии[1];
	
КонецФункции

Функция ПолучитьИмяCOMСоединителя(ТипСоединения = "Application")
	
	ВерсияCOMСоединения = ПолучитьВерсиюCOMСоединения();
	
	Возврат ВерсияCOMСоединения + "." + ТипСоединения;
	
КонецФункции

Функция УстановитьCOMСоединениеСБазойApplication(Конфигурация, КаталогКонфигурации, Пользователь, Пароль)
	
	Результат = Новый Структура;
	Результат.Вставить("Успешно", Ложь);
	Результат.Вставить("Сообщение", "");
	
	Каталог = КаталогКонфигурации;
	Если ПустаяСтрока(Каталог) Тогда
		Каталог = Конфигурация.КаталогКонфигурации;
	КонецЕсли;
	
	Каталог = ПолучитьПутьКБазе(Каталог);
	СтрокаСоединения = ПолучитьСтрокуСоединенияСБазой(Каталог, Пользователь, Пароль);
	
	ИмяCOMОбъекта = ПолучитьИмяCOMСоединителя();
	Попытка
		
		ТекущаяБаза = Новый COMОбъект(ИмяCOMОбъекта);
		ТекущаяБаза.Connect(СтрокаСоединения);
		ТекущаяБаза.Visible = 0;
		
		Результат = ПроверитьРежимСовместимости(ТекущаяБаза);
		
		Если Результат.Успешно Тогда
			Результат = ПроверитьЗащитуОтОпасныхДействий(ТекущаяБаза, Конфигурация);
		КонецЕсли;
		
	Исключение
		ИнформацияОбОшибке = ИнформацияОбОшибке();
		Результат.Сообщение = ПодробноеПредставлениеОшибки(ИнформацияОбОшибке);
	КонецПопытки;
	
	ЗавершитьCOMСоединениеСБазой(ТекущаяБаза);
	
	Возврат Результат;
	
КонецФункции

// Проверяет, возможно ли установить внешнее соединение с базой с целью проверки
// параметров подключения к ней. Если подключение успешно, возвращается Истина, иначе Ложь.
//
Функция УстановитьCOMСоединениеСБазой(Конфигурация, КаталогКонфигурации = "", Пользователь = "", Пароль = "") Экспорт
	
	Результат = Новый Структура;
	Результат.Вставить("Успешно", Ложь);
	Результат.Вставить("Сообщение", "");
	
	Каталог = КаталогКонфигурации;
	Если ПустаяСтрока(Каталог) Тогда
		Каталог = Конфигурация.КаталогКонфигурации;
	КонецЕсли;
	
	Если НЕ ДемоБазаСуществует(Каталог) Тогда
		Результат.Сообщение = НСтр("ru='Проверяемая база не существует в указанном каталоге.'");
		Возврат Результат;
	КонецЕсли;
	
	// Регистрируем COM-объект Application для текущего пользователя.
	Результат = ЗарегистрироватьCOMApplication(Конфигурация.СтрокаЗапускаПлатформы);
	Если НЕ Результат.Успешно Тогда
		Возврат Результат;
	КонецЕсли;
	
	// Проверяем COM-соединение по Application.
	Результат = УстановитьCOMСоединениеСБазойApplication(Конфигурация, КаталогКонфигурации, Пользователь, Пароль);
	
	Возврат Результат;
	
КонецФункции

Процедура ЗавершитьCOMСоединениеСБазой(ТекущаяБаза)
	
	Попытка
		ТекущаяБаза.ПрекратитьРаботуСистемы();
	Исключение
	КонецПопытки;
	
	ТекущаяБаза = Неопределено;
	
КонецПроцедуры

// Проверяет, возможно ли установить внешнее соединение с базой с целью проверки
// параметров подключения к ней. Если подключение успешно, возвращается COMОбъект.
//
Функция СоздатьCOMОбъектБазы(Конфигурация, КаталогКонфигурации = "", Пользователь = "", Пароль = "")
	
	Каталог = КаталогКонфигурации;
	Если ПустаяСтрока(Каталог) Тогда
		Каталог = Конфигурация.КаталогКонфигурации;
	КонецЕсли;
	
	Каталог = ПолучитьПутьКБазе(Каталог);
	СтрокаСоединения = ПолучитьСтрокуСоединенияСБазой(Каталог, Пользователь, Пароль);
	
	ИмяCOMОбъекта = ПолучитьИмяCOMСоединителя();
	Попытка
		ТекущаяБаза = Новый COMОбъект(ИмяCOMОбъекта);
		ТекущаяБаза.Connect(СтрокаСоединения);
		ТекущаяБаза.Visible = 0;
	Исключение
		ИнформацияОбОшибке = ИнформацияОбОшибке();
		Возврат ПодробноеПредставлениеОшибки(ИнформацияОбОшибке);
	КонецПопытки;
	
	Возврат ТекущаяБаза;
	
КонецФункции

// Получает режим запуска приложения.
// Параметры:
//   КаталогКонфигурации - каталог базы.
//	 Пользователь - имя пользователя базы.
//	 Пароль - пароль пользователя базы.
// Возвращаемое значение:
//   Строка - ключ запуска приложения.
Функция ПолучитьРежимЗапускаПриложения(Конфигурация, КаталогКонфигурации = "", Пользователь = "", Пароль = "") Экспорт
	
	КлючЗапускаОбычногоПриложения = " /RunModeOrdinaryApplication";
	КлючЗапускаУправляемогоПриложения = " /RunModeManagedApplication";
	
	Каталог = КаталогКонфигурации;
	Если ПустаяСтрока(Каталог) Тогда
		Каталог = Конфигурация.КаталогКонфигурации;
	КонецЕсли;
	
	ТекущаяБаза = СоздатьCOMОбъектБазы(Конфигурация, Каталог, Пользователь, Пароль);
	
	Если ТипЗнч(ТекущаяБаза) <> Тип("COMОбъект") Тогда
		Возврат "";
	КонецЕсли;
	
	КлючЗапуска = "";
	Попытка
		
		РежимЗапуска = ТекущаяБаза.ТекущийРежимЗапуска();
		
		Если РежимЗапуска = ТекущаяБаза.РежимЗапускаКлиентскогоПриложения.ОбычноеПриложение Тогда
			КлючЗапуска = КлючЗапускаОбычногоПриложения;
		ИначеЕсли РежимЗапуска = ТекущаяБаза.РежимЗапускаКлиентскогоПриложения.УправляемоеПриложение Тогда
			КлючЗапуска = КлючЗапускаУправляемогоПриложения;
		ИначеЕсли РежимЗапуска = ТекущаяБаза.РежимЗапускаКлиентскогоПриложения.Авто Тогда
			ОсновнойРежимЗапускаКонфигурации = ТекущаяБаза.Метаданные.ОсновнойРежимЗапуска;
			Если ОсновнойРежимЗапускаКонфигурации = ТекущаяБаза.РежимЗапускаКлиентскогоПриложения.ОбычноеПриложение Тогда
				КлючЗапуска = КлючЗапускаОбычногоПриложения;
			Иначе
				КлючЗапуска = КлючЗапускаУправляемогоПриложения;
			КонецЕсли;
		КонецЕсли;
		
	Исключение
		КлючЗапуска = "НеПолучен";
	КонецПопытки;
	
	ЗавершитьCOMСоединениеСБазой(ТекущаяБаза);
	
	Возврат КлючЗапуска;
	
КонецФункции

Функция ПолучитьСтрокуСоединенияСБазой(Знач Каталог, Знач Пользователь = "", Знач Пароль = "")
	
	Каталог = ПолучитьПутьКБазе(Каталог);
	СтрокаАутентификации = "";
	
	СтрокаАутентификации = "Usr=""" + Пользователь + """;Pwd=""" + Пароль + """;";
	
	КаталогИББезСлэша = Лев(Каталог, СтрДлина(Каталог) - 1);
	СтрокаСоединения = " File=""" + КаталогИББезСлэша + """;" + СтрокаАутентификации;
	
	Возврат СтрокаСоединения;
	
КонецФункции

// Преобразует каталог базы
//
Функция ПолучитьПутьКБазе(Знач Каталог)
	
	Если НЕ ЗначениеЗаполнено(Каталог) Тогда
		Возврат "";
	КонецЕсли;
	
	Каталог = СокрЛП(Каталог);
	
	// Если на вход подается строка соединения с файловой базой, то получаем каталог из строки соединения.
	Если СтрНайти(Каталог, "File=") Тогда
		ИтоговаяСтрока = ПолучитьЗначениеПараметраСтрокиСоединения(Каталог, "File");
		Возврат ИтоговаяСтрока + ?(СтрЗаканчиваетсяНа(ИтоговаяСтрока, "\"), "", "\");
	КонецЕсли;
	
	// убираем имя файла из конца пути к базе
	КаталогБазы = ?(СтрНайти(ВРег("" + Каталог), "1CV8.1CD") = 0, Каталог, ФайлПолучитьКаталог(Каталог));
	Возврат КаталогБазы + ?(СтрЗаканчиваетсяНа(КаталогБазы, "\"), "", "\");
	
КонецФункции

Функция ПолучитьЗначениеПараметраСтрокиСоединения(СтрокаСоединения, ИмяПараметра)
	
	МассивЭлементовСоединения = СтрРазделить(СтрокаСоединения, ";", Ложь);
	
	СтрокаПараметра = "";
	Для Каждого ТекущийЭлемент Из МассивЭлементовСоединения Цикл
		Если СтрНайти("" + ТекущийЭлемент, ИмяПараметра + "=") > 0 Тогда
			СтрокаПараметра = СокрЛП("" + ТекущийЭлемент);
			Прервать;
		КонецЕсли;
	КонецЦикла;
	
	Если ПустаяСтрока(СтрокаПараметра) Тогда
		Возврат "";
	КонецЕсли;
	
	СтрокаПослеИмениПараметра = СокрЛП(Прав(СтрокаПараметра, СтрДлина(СтрокаПараметра) - СтрДлина(ИмяПараметра) - 1));
	ЗначениеПараметра = СтрокаПослеИмениПараметра;
	
	Если СтрНачинаетсяС(СтрокаПослеИмениПараметра, """") Тогда
		ЗначениеПараметра = Прав(ЗначениеПараметра, СтрДлина(ЗначениеПараметра) - 1);
	КонецЕсли;
	
	Если СтрЗаканчиваетсяНа(СтрокаПослеИмениПараметра, """") Тогда
		ЗначениеПараметра = Лев(ЗначениеПараметра, СтрДлина(ЗначениеПараметра) - 1);
	КонецЕсли;
	
	Возврат СокрЛП(ЗначениеПараметра);
	
КонецФункции

// Определяет факт отличия основной конфигурации от конфигурации базы данных.
// Параметры:
//   Конфигурация - Ссылка запускаемого приложения.
// Возвращаемое значение:
//   Булево.
//
Функция КонфигурацияСоответствуетБД(Конфигурация, КаталогКонфигурации = "", Пользователь = "", Пароль = "") Экспорт
	
	Каталог = КаталогКонфигурации;
	ТекущаяБаза = СоздатьCOMОбъектБазы(Конфигурация, Каталог, Пользователь, Пароль);
	
	Если ТипЗнч(ТекущаяБаза) <> Тип("COMОбъект") Тогда
		Возврат Ложь;
	КонецЕсли;
	
	Попытка
		ФлагКонфигурацияСоответствуетБД = НЕ ТекущаяБаза.КонфигурацияИзменена();
	Исключение
		ФлагКонфигурацияСоответствуетБД = Истина;
	КонецПопытки;
	
	ЗавершитьCOMСоединениеСБазой(ТекущаяБаза);
	
	Возврат ФлагКонфигурацияСоответствуетБД;
	
КонецФункции

// Определяет факт отличия основной конфигурации от конфигурации базы данных.
// Параметры:
//   Конфигурация - Ссылка запускаемого приложения.
// Возвращаемое значение:
//   Булево.
//
Функция ПолучитьРежимИспользованияМодальности(Конфигурация, КаталогКонфигурации = "", Пользователь = "", Пароль = "") Экспорт
	
	Каталог = КаталогКонфигурации;
	ТекущаяБаза = СоздатьCOMОбъектБазы(Конфигурация, Каталог, Пользователь, Пароль);
	
	Если ТипЗнч(ТекущаяБаза) <> Тип("COMОбъект") Тогда
		Возврат Ложь;
	КонецЕсли;
	
	Попытка
		РежимИспользованияМодальности =
			(ТекущаяБаза.Метаданные.РежимИспользованияМодальности =
				ТекущаяБаза.Метаданные.СвойстваОбъектов.РежимИспользованияМодальности.Использовать);
	Исключение
		РежимИспользованияМодальности = Ложь;
	КонецПопытки;
	
	ЗавершитьCOMСоединениеСБазой(ТекущаяБаза);
	
	Возврат РежимИспользованияМодальности;
	
КонецФункции

// Выполняет обработчик обновления информационной базы, если в конфигурации есть подсистема "СтандартныеПодсистемы".
//
Функция ПолучитьВерсиюКонфигурации(Конфигурация, КаталогКонфигурации = "", Пользователь = "", Пароль = "") Экспорт
	
	Результат = Новый Структура;
	Результат.Вставить("Успешно", Ложь);
	Результат.Вставить("Сообщение", "");
	
	Каталог = КаталогКонфигурации;
	ТекущаяБаза = СоздатьCOMОбъектБазы(Конфигурация, Каталог, Пользователь, Пароль);
	
	Если ТипЗнч(ТекущаяБаза) <> Тип("COMОбъект") Тогда
		ТекстОшибки = НСтр("ru='Не удалось подключиться к базе через COM-соединение.'") + Символы.ПС + Строка(ТекущаяБаза);
		Результат.Сообщение = ТекстОшибки;
		Возврат Результат;
	КонецЕсли;
	
	Попытка
		Результат.Сообщение = ТекущаяБаза.Метаданные.Версия;
		Результат.Успешно = Истина;
	Исключение
		ИнформацияОбОшибке = ИнформацияОбОшибке();
		ТекстОшибки = СтрШаблон(НСтр("ru='Не удалось получить версию проверяемой конфигурации по причине:%1%2'"), Символы.ПС,
			ПодробноеПредставлениеОшибки(ИнформацияОбОшибке));
		Результат.Сообщение = ТекстОшибки;
	КонецПопытки;
	
	ЗавершитьCOMСоединениеСБазой(ТекущаяБаза);
	
	Возврат Результат;
	
КонецФункции

Функция ПолучитьВерсиюБСПИзCOMОбъекта(ТекущаяБаза, ТекстОшибки = "")
	
	ВерсияБСП = "";
	Попытка
		ВерсияБСП = ТекущаяБаза.СтандартныеПодсистемыСервер.ВерсияБиблиотеки();
	Исключение
		ИнформацияОбОшибке = ИнформацияОбОшибке();
		ТекстОшибки = ПодробноеПредставлениеОшибки(ИнформацияОбОшибке);
	КонецПопытки;
	
	Возврат ВерсияБСП;
	
КонецФункции

// Получает версию библиотеки стандартных подсистем.
//
Функция ПолучитьВерсиюБСП(Конфигурация, КаталогКонфигурации = "", Пользователь = "", Пароль = "") Экспорт
	
	ТекущаяБаза = СоздатьCOMОбъектБазы(Конфигурация, КаталогКонфигурации, Пользователь, Пароль);
	
	Если ТипЗнч(ТекущаяБаза) <> Тип("COMОбъект") Тогда
		Возврат "";
	КонецЕсли;
	
	ВерсияБСП = ПолучитьВерсиюБСПИзCOMОбъекта(ТекущаяБаза);
	
	ЗавершитьCOMСоединениеСБазой(ТекущаяБаза);
	
	Возврат ВерсияБСП;
	
КонецФункции

// Выполняет процедуры для получения назначения ролей в проверяемой базе в COM-объекте.
// Возвращаемое значение:
//   НазначениеРолей - структура, содержащая массивы ролей.
//
Функция ПолучитьНазначениеРолей(Конфигурация, КаталогКонфигурации = "", Пользователь = "", Пароль = "") Экспорт
	
	НазначениеРолей = Новый Структура;
	НазначениеРолей.Вставить("ТолькоДляАдминистраторовСистемы", Новый Массив);
	НазначениеРолей.Вставить("ТолькоДляПользователейСистемы", Новый Массив);
	НазначениеРолей.Вставить("ТолькоДляВнешнихПользователей", Новый Массив);
	НазначениеРолей.Вставить("СовместноДляПользователейИВнешнихПользователей", Новый Массив);
	НазначениеРолей.Вставить("БазаСкопированаУспешно", Ложь);
	НазначениеРолей.Вставить("УстановленоCOMСоединение", Ложь);
	НазначениеРолей.Вставить("ВерсияБСП", "");
	НазначениеРолей.Вставить("ТекстОшибки", "");
	
	КаталогКопииБазы = ПолучитьКаталогВременныхФайлов();
	
	// Копируем базу, чтобы получить назначение ролей из копии базы.
	// Т.о. пытаемся решить проблему с одновременным подключением к базе на разных версиях платформы.
	ТекстОшибки = КопироватьБазу(КаталогКонфигурации, КаталогКопииБазы);
	Если НЕ ПустаяСтрока(ТекстОшибки) Тогда
		НазначениеРолей.Вставить("ТекстОшибки", ТекстОшибки);
		ФайлУдалить(КаталогКопииБазы);
		Возврат НазначениеРолей;
	КонецЕсли;
	
	НазначениеРолей.Вставить("БазаСкопированаУспешно", Истина);
	
	ТекущаяБаза = СоздатьCOMОбъектБазы(Конфигурация, КаталогКопииБазы, Пользователь, Пароль);
	
	Если ТипЗнч(ТекущаяБаза) <> Тип("COMОбъект") Тогда
		НазначениеРолей.Вставить("ТекстОшибки", Строка(ТекущаяБаза));
		ФайлУдалить(КаталогКопииБазы);
		Возврат НазначениеРолей;
	КонецЕсли;
	
	НазначениеРолей.Вставить("УстановленоCOMСоединение", Истина);
	
	// Получаем версию БСП.
	ВерсияБСП = ПолучитьВерсиюБСПИзCOMОбъекта(ТекущаяБаза, ТекстОшибки);
	НазначениеРолей.Вставить("ВерсияБСП", ВерсияБСП);
	
	// Если не удалось определить версию БСП, то выходим.
	Если НЕ ПустаяСтрока(ТекстОшибки) Тогда
		ЗавершитьCOMСоединениеСБазой(ТекущаяБаза);
		НазначениеРолей.Вставить("ТекстОшибки", ТекстОшибки);
		ФайлУдалить(КаталогКопииБазы);
		Возврат НазначениеРолей;
	КонецЕсли;
	
	// Получаем назначение ролей.
	Попытка
		
		Если РелизыПоПорядку(ВерсияБСП, "2.3.2.0") Тогда
			// Если версия БСП ниже 2.3.2, тогда назначение ролей считывать не нужно.
			
		ИначеЕсли РелизыПоПорядку(ВерсияБСП, "2.4.1.0") Тогда
			// Если версия БСП ниже 2.4.1, тогда считываем из 2-х модулей.
			ТекущаяБаза.ПользователиПереопределяемый.ПриОпределенииНазначенияРолей(НазначениеРолей);
			ТекущаяБаза.ИнтеграцияСтандартныхПодсистем.ПриОпределенииНазначенияРолей(НазначениеРолей);
			
		Иначе
			// Если версия БСП 2.4.1 или выше, то вызываем Пользователи.НазначениеРолей().
			ПользователиНазначениеРолей = ТекущаяБаза.Пользователи.НазначениеРолей();
			
			// Функция возвращает COM-Объект, а не структуру, поэтому перенесем элементы в цикле.
			// ЗаполнитьЗначенияСвойств() не сработает, т.к. заполнит структуру элементами с типом COM-Объект, а надо массивы.
			Для Каждого Элемент Из ПользователиНазначениеРолей Цикл
				МассивРолей = Новый Массив;
				Для Каждого ЭлементЗначения Из Элемент.Значение Цикл
					МассивРолей.Добавить(ЭлементЗначения);
				КонецЦикла;
				
				НазначениеРолей.Вставить(Элемент.Ключ, МассивРолей);
			КонецЦикла;
		КонецЕсли;
		
	Исключение
		ИнформацияОбОшибке = ИнформацияОбОшибке();
		ТекстОшибки = ПодробноеПредставлениеОшибки(ИнформацияОбОшибке);
		НазначениеРолей.Вставить("ТекстОшибки", ТекстОшибки);
	КонецПопытки;
	
	ЗавершитьCOMСоединениеСБазой(ТекущаяБаза);
	ФайлУдалить(КаталогКопииБазы);
	
	Возврат НазначениеРолей;
	
КонецФункции

Функция ПроверитьРежимСовместимости(ТекущаяБаза)
	
	Результат = Новый Структура;
	Результат.Вставить("Успешно", Ложь);
	Результат.Вставить("Сообщение", "");
	
	ТекстОшибкиШаблон = НСтр("ru='%1
		|Текущая версия программы предназначена для проверки конфигураций с режимом совместимости 8.3.6 или выше.
		|Для проверки выбранной конфигурации воспользуйтесь более ранней версией программы АПК.'");
	
	Если ТипЗнч(ТекущаяБаза) <> Тип("COMОбъект") Тогда
		Результат.Сообщение = СтрШаблон(ТекстОшибкиШаблон, НСтр("ru='Не удалось получить режим совместимости конфигурации.'"));
		Возврат Результат;
	КонецЕсли;
	
	РежимСовместимостиСтрока = "";
	Попытка
		РежимСовместимости = ТекущаяБаза.Метаданные.РежимСовместимости;
		
		Если РежимСовместимости = ТекущаяБаза.Метаданные.СвойстваОбъектов.РежимСовместимости.Версия8_1 Тогда
			РежимСовместимостиСтрока = "8.1";
		ИначеЕсли РежимСовместимости = ТекущаяБаза.Метаданные.СвойстваОбъектов.РежимСовместимости.Версия8_2_13 Тогда
			РежимСовместимостиСтрока = "8.2.13";
		ИначеЕсли РежимСовместимости = ТекущаяБаза.Метаданные.СвойстваОбъектов.РежимСовместимости.Версия8_2_16 Тогда
			РежимСовместимостиСтрока = "8.2.16";
		ИначеЕсли РежимСовместимости = ТекущаяБаза.Метаданные.СвойстваОбъектов.РежимСовместимости.Версия8_3_1 Тогда
			РежимСовместимостиСтрока = "8.3.1";
		ИначеЕсли РежимСовместимости = ТекущаяБаза.Метаданные.СвойстваОбъектов.РежимСовместимости.Версия8_3_2 Тогда
			РежимСовместимостиСтрока = "8.3.2";
		ИначеЕсли РежимСовместимости = ТекущаяБаза.Метаданные.СвойстваОбъектов.РежимСовместимости.Версия8_3_3 Тогда
			РежимСовместимостиСтрока = "8.3.3";
		ИначеЕсли РежимСовместимости = ТекущаяБаза.Метаданные.СвойстваОбъектов.РежимСовместимости.Версия8_3_4 Тогда
			РежимСовместимостиСтрока = "8.3.4";
		ИначеЕсли РежимСовместимости = ТекущаяБаза.Метаданные.СвойстваОбъектов.РежимСовместимости.Версия8_3_5 Тогда
			РежимСовместимостиСтрока = "8.3.5";
		КонецЕсли;
	Исключение
		Результат.Сообщение = СтрШаблон(ТекстОшибкиШаблон, НСтр("ru='Не удалось получить режим совместимости конфигурации.'"));
		Возврат Результат;
	КонецПопытки;
	
	Если ПустаяСтрока(РежимСовместимостиСтрока) Тогда
		Результат.Успешно = Истина;
		Возврат Результат;
	КонецЕсли;
	
	ТекстОшибки = СтрШаблон(НСтр("ru='Режим совместимости проверяемой конфигурации %1.'"), РежимСовместимостиСтрока);
	Результат.Сообщение = СтрШаблон(ТекстОшибкиШаблон, ТекстОшибки);
	
	Возврат Результат;
	
КонецФункции

Функция ПолучитьШаблоныЗаданийОчереди(Конфигурация, КаталогКонфигурации = "", Пользователь = "", Пароль = "") Экспорт
	
	Каталог = КаталогКонфигурации;
	ТекущаяБаза = СоздатьCOMОбъектБазы(Конфигурация, Каталог, Пользователь, Пароль);
	
	Если ТипЗнч(ТекущаяБаза) <> Тип("COMОбъект") Тогда
		Возврат Неопределено;
	КонецЕсли;
	
	МассивШаблонов = Новый Массив;
	
	Попытка
		ШаблоныЗаданийОчереди = ТекущаяБаза.ОчередьЗаданий.ШаблоныЗаданийОчереди();
		// Функция возвращает COM-Объект, а не массив, поэтому перенесем элементы в цикле.
		Для Каждого Шаблон Из ШаблоныЗаданийОчереди Цикл
			МассивШаблонов.Добавить(Шаблон);
		КонецЦикла;
	Исключение
		МассивШаблонов = Неопределено;
	КонецПопытки;
	
	ЗавершитьCOMСоединениеСБазой(ТекущаяБаза);
	
	Возврат МассивШаблонов;
	
КонецФункции

Функция ПолучитьРегламентныеЗаданияЗависимыеОтФункциональныхОпций(Конфигурация, КаталогКонфигурации = "",
	Пользователь = "", Пароль = "") Экспорт
	
	Каталог = КаталогКонфигурации;
	ТекущаяБаза = СоздатьCOMОбъектБазы(Конфигурация, Каталог, Пользователь, Пароль);
	
	Если ТипЗнч(ТекущаяБаза) <> Тип("COMОбъект") Тогда
		Возврат Неопределено;
	КонецЕсли;
	
	ТаблицаРегламентныхЗаданий = Новый ТаблицаЗначений;
	
	Попытка
		
		ТаблицаРегламентныхЗаданийCOMОбъект =
			ТекущаяБаза.РегламентныеЗаданияСлужебный.РегламентныеЗаданияЗависимыеОтФункциональныхОпций();
		
		// Функция возвращает COM-Объект, а не таблицу, поэтому перенесем колонки и строки в цикле.
		// (Метод СкопироватьКолонки()/CopyColumns() в данном случае также вернет COM-Объект).
		Для Каждого КолонкаТаблицы Из ТаблицаРегламентныхЗаданийCOMОбъект.Колонки Цикл
			ТаблицаРегламентныхЗаданий.Колонки.Добавить(КолонкаТаблицы.Имя);
		КонецЦикла;
		
		Для Каждого СтрокаТаблицы Из ТаблицаРегламентныхЗаданийCOMОбъект Цикл
			
			НоваяСтрока = ТаблицаРегламентныхЗаданий.Добавить();
			ЗаполнитьЗначенияСвойств(НоваяСтрока, СтрокаТаблицы);
			
			// Проверяем, типы значений в колонках, если COM-Объект, то переопределим значение наименованием.
			Для Каждого КолонкаТаблицы Из ТаблицаРегламентныхЗаданий.Колонки Цикл
				
				ИмяКолонки = КолонкаТаблицы.Имя;
				
				Значение = НоваяСтрока[ИмяКолонки];
				Если ТипЗнч(Значение) <> Тип("COMОбъект") Тогда
					Продолжить;
				КонецЕсли;
				
				// Пытаемся получить наименование COM-Объекта и перезаписать им значение в строке.
				Попытка
					НаименованиеОбъекта = Значение.Имя;
				Исключение
					НаименованиеОбъекта = "";
				КонецПопытки;
				
				НоваяСтрока[ИмяКолонки] = НаименованиеОбъекта;
				
			КонецЦикла;
			
		КонецЦикла;
		
	Исключение
		
		ТаблицаРегламентныхЗаданий = Неопределено;
		
	КонецПопытки;
	
	ЗавершитьCOMСоединениеСБазой(ТекущаяБаза);
	
	Возврат ТаблицаРегламентныхЗаданий;
	
КонецФункции

Функция ПолучитьИтерацииОбновления(Конфигурация, КаталогКонфигурации = "", Пользователь = "", Пароль = "") Экспорт
	
	Каталог = КаталогКонфигурации;
	ТекущаяБаза = СоздатьCOMОбъектБазы(Конфигурация, Каталог, Пользователь, Пароль);
	
	Если ТипЗнч(ТекущаяБаза) <> Тип("COMОбъект") Тогда
		Возврат Неопределено;
	КонецЕсли;
	
	ТаблицаИтерацийОбновления = Новый ТаблицаЗначений;
	ТаблицаИтерацийОбновления.Колонки.Добавить("ПараллельноеОтложенноеОбновлениеСВерсии");
	ТаблицаИтерацийОбновления.Колонки.Добавить("Подсистема");
	ТаблицаИтерацийОбновления.Колонки.Добавить("НачальноеЗаполнение");
	ТаблицаИтерацийОбновления.Колонки.Добавить("Версия");
	ТаблицаИтерацийОбновления.Колонки.Добавить("Процедура");
	ТаблицаИтерацийОбновления.Колонки.Добавить("РежимВыполнения");
	ТаблицаИтерацийОбновления.Колонки.Добавить("ВыполнятьВГруппеОбязательных");
	ТаблицаИтерацийОбновления.Колонки.Добавить("ОбщиеДанные");
	ТаблицаИтерацийОбновления.Колонки.Добавить("УправлениеОбработчиками");
	ТаблицаИтерацийОбновления.Колонки.Добавить("Комментарий");
	ТаблицаИтерацийОбновления.Колонки.Добавить("Идентификатор");
	ТаблицаИтерацийОбновления.Колонки.Добавить("ПроцедураПроверки");
	ТаблицаИтерацийОбновления.Колонки.Добавить("БлокируемыеОбъекты");
	ТаблицаИтерацийОбновления.Колонки.Добавить("ПроцедураЗаполненияДанныхОбновления");
	ТаблицаИтерацийОбновления.Колонки.Добавить("ОчередьОтложеннойОбработки");
	ТаблицаИтерацийОбновления.Колонки.Добавить("ЗапускатьТолькоВГлавномУзле");
	ТаблицаИтерацийОбновления.Колонки.Добавить("ЗапускатьИВПодчиненномУзлеРИБСФильтрами");
	ТаблицаИтерацийОбновления.Колонки.Добавить("ЧитаемыеОбъекты");
	ТаблицаИтерацийОбновления.Колонки.Добавить("ИзменяемыеОбъекты");
	ТаблицаИтерацийОбновления.Колонки.Добавить("Приоритет");
	ТаблицаИтерацийОбновления.Колонки.Добавить("МонопольныйРежим");
	
	Попытка
		
		МассивОписанийПодсистем = ТекущаяБаза.СтандартныеПодсистемыПовтИсп.ОписанияПодсистем().ПоИменам;
		
		Для Каждого ОписаниеПодсистемы Из МассивОписанийПодсистем Цикл
			
			Обработчики = ТекущаяБаза.ОбновлениеИнформационнойБазы.НоваяТаблицаОбработчиковОбновления();
			ОсновнойСерверныйМодуль = ОписаниеПодсистемы.Значение.ОсновнойСерверныйМодуль;
			Модуль = ТекущаяБаза.ОбщегоНазначения.ОбщийМодуль(ОсновнойСерверныйМодуль);
			Модуль.ПриДобавленииОбработчиковОбновления(Обработчики);
			
			ПараллельноеОтложенноеОбновлениеСВерсии = ОписаниеПодсистемы.Значение.ПараллельноеОтложенноеОбновлениеСВерсии;
			ПодсистемаИмя = ОписаниеПодсистемы.Значение.Имя;
			
			Для Каждого Обработчик Из Обработчики Цикл
				
				НоваяСтрока = ТаблицаИтерацийОбновления.Добавить();
				ЗаполнитьЗначенияСвойств(НоваяСтрока, Обработчик,, "Идентификатор");
				
				НоваяСтрока.ПараллельноеОтложенноеОбновлениеСВерсии = ПараллельноеОтложенноеОбновлениеСВерсии;
				НоваяСтрока.Подсистема = ПодсистемаИмя;
				НоваяСтрока.Идентификатор = ЗначениеИзСтрокиВнутр(ТекущаяБаза.ЗначениеВСтрокуВнутр(Обработчик.Идентификатор));
				
			КонецЦикла;
			
		КонецЦикла;
		
	Исключение
		ТаблицаИтерацийОбновления = Неопределено;
	КонецПопытки;
	
	ЗавершитьCOMСоединениеСБазой(ТекущаяБаза);
	
	Возврат ТаблицаИтерацийОбновления;
	
КонецФункции

Функция ПроверитьЗащитуОтОпасныхДействий(ТекущаяБаза, Конфигурация)
	
	Результат = Новый Структура;
	Результат.Вставить("Успешно", Истина);
	Результат.Вставить("Сообщение", "");
	
	// Начиная с версий 8.3.8.2027 и 8.3.9.2033 в платформе появилось предупреждение безопасности.
	// Необходимо отключить механизм защиты от опасных действий в настройках пользователя проверяемой базы.
	
	ИмяПользователя = "";
	Попытка
		
		ТекущийПользователь = ТекущаяБаза.ПользователиИнформационнойБазы.ТекущийПользователь();
		ИмяПользователя = ТекущийПользователь.Имя;
		
		// Проверим наличие свойства "ЗащитаОтОпасныхДействий" у пользователя, чтобы не проверять версию платформы.
		// Проверяем наличие свойства на русском и английском языках, т.к. на русском иногда не считывается.
		СвойстваПользователя = Новый Структура("UnsafeActionProtection, UnsafeOperationProtection, ЗащитаОтОпасныхДействий");
		ЗаполнитьЗначенияСвойств(СвойстваПользователя, ТекущийПользователь);
		
		// Если свойство "ЗащитаОтОпасныхДействий" у пользователя отсутствует, значит, отключать нечего, выходим.
		Если (СвойстваПользователя.UnsafeActionProtection = Неопределено)
		   И (СвойстваПользователя.UnsafeOperationProtection = Неопределено)
		   И (СвойстваПользователя.ЗащитаОтОпасныхДействий = Неопределено) Тогда
			Возврат Результат;
		КонецЕсли;
		
		ПредупреждатьОбОпасныхДействиях = ТекущийПользователь.ЗащитаОтОпасныхДействий.ПредупреждатьОбОпасныхДействиях;
		
		// Если защита от опасных действий отключена, то выходим.
		Если НЕ ПредупреждатьОбОпасныхДействиях Тогда
			Возврат Результат;
		КонецЕсли;
		
		// Иначе пытаемся ее отключить.
		ОписаниеЗащитыОтОпасныхДействий = ТекущаяБаза.NewObject("ОписаниеЗащитыОтОпасныхДействий");
		ОписаниеЗащитыОтОпасныхДействий.ПредупреждатьОбОпасныхДействиях = Ложь;
		
		ТекущийПользователь.ЗащитаОтОпасныхДействий = ОписаниеЗащитыОтОпасныхДействий;
		ТекущийПользователь.Записать();
		
	Исключение
		
		ИнформацияОбОшибке = ИнформацияОбОшибке();
		ПодробноеПредставлениеОшибки = ПодробноеПредставлениеОшибки(ИнформацияОбОшибке);
		
		ТекстОшибки = НСтр("ru='Не удалось отключить защиту от опасных действий для пользователя по причине:%1%2%1'");
		ТекстОшибки = СтрШаблон(ТекстОшибки, Символы.ПС, ПодробноеПредставлениеОшибки);
		
		// Добавим сообщение в текст ошибки.
		ДополнительноеСообщение = НСтр("ru='Необходимо %1отключить механизм защиты от опасных действий.'");
		
		// Если в базе нет пользователей, то предложим добавить администратора с полными правами.
		ТекстЗамены = "";
		Если ПустаяСтрока(ИмяПользователя) Тогда
			ТекстЗамены = НСтр("ru='добавить пользователя с полными правами в проверяемую информационную базу или'") + " ";
		КонецЕсли;
		
		ДополнительноеСообщение = СтрШаблон(ДополнительноеСообщение, ТекстЗамены);
		ТекстОшибки = ТекстОшибки + ДополнительноеСообщение;
		
		Результат.Сообщение = ТекстОшибки;
		Результат.Успешно = Ложь;
		
	КонецПопытки;
	
	Возврат Результат;
	
КонецФункции

Функция ПолучитьВерсииФорматаОбменаEnterpriseData(Конфигурация, КаталогКонфигурации = "", Пользователь = "",
	Пароль = "", ВерсияБСП = "") Экспорт
	
	Если ПустаяСтрока(ВерсияБСП) Тогда
		Возврат Неопределено;
	КонецЕсли;
	
	Каталог = КаталогКонфигурации;
	ТекущаяБаза = СоздатьCOMОбъектБазы(Конфигурация, Каталог, Пользователь, Пароль);
	
	Если ТипЗнч(ТекущаяБаза) <> Тип("COMОбъект") Тогда
		Возврат Неопределено;
	КонецЕсли;
	
	СписокПлановОбмена = Новый СписокЗначений;
	
	// Получаем список планов обмена БСП.
	Попытка
		
		СписокПлановОбменаБСП = ТекущаяБаза.ОбменДаннымиПовтИсп.СписокПлановОбменаБСП();
		
		// Функция возвращает COM-Объект, а не список значений, поэтому перенесем элементы в цикле.
		Для Каждого ЭлементПланаОбмена Из СписокПлановОбменаБСП Цикл
			СписокПлановОбмена.Добавить(ЭлементПланаОбмена.Значение);
		КонецЦикла;
		
	Исключение
		ЗавершитьCOMСоединениеСБазой(ТекущаяБаза);
		Возврат Неопределено;
	КонецПопытки;
	
	Если СписокПлановОбмена.Количество() = 0 Тогда
		ЗавершитьCOMСоединениеСБазой(ТекущаяБаза);
		Возврат Неопределено;
	КонецЕсли;
	
	ТаблицаВерсийФорматаОбмена = Новый ТаблицаЗначений;
	ТаблицаВерсийФорматаОбмена.Колонки.Добавить("ПланОбмена");
	ТаблицаВерсийФорматаОбмена.Колонки.Добавить("ВерсииФорматаОбмена");
	
	ВерсияБСП243ИлиВыше = РелизыПоПорядку("2.4.3.0", ВерсияБСП);
	ВерсияКонфигурации = НайтиПоследнююВерсию(Конфигурация, Ложь);
	
	// Получаем перечень поддерживаемых версий формата обмена EnterpriseData.
	Для Каждого ЭлементПланаОбмена Из СписокПлановОбмена Цикл
		
		Попытка
			
			ИмяПланаОбмена = ЭлементПланаОбмена.Значение;
			ЭтоПланОбменаXDTO = ТекущаяБаза.ОбменДаннымиПовтИсп.ЭтоПланОбменаXDTO(ИмяПланаОбмена);
			
			// Пропускаем планы обмена, не использующие формат обмена EnterpriseData.
			Если ЭтоПланОбменаXDTO <> Истина Тогда
				Продолжить;
			КонецЕсли;
			
			// Получаем список версий формата обмена.
			Если ВерсияБСП243ИлиВыше Тогда
				ПоддерживаемыеВерсииБСП = ТекущаяБаза.ОбменДаннымиСервер.ЗначениеНастройкиПланаОбмена(ИмяПланаОбмена,
					"ВерсииФорматаОбмена");
			Иначе
				ПоддерживаемыеВерсииБСП = Новый Соответствие;
				ТекущаяБаза.ПланыОбмена[ИмяПланаОбмена].ПолучитьВерсииФорматаОбмена(ПоддерживаемыеВерсииБСП);
			КонецЕсли;
			
			ПоддерживаемыеВерсии = Новый Массив;
			Для Каждого ЭлементВерсииФормата Из ПоддерживаемыеВерсииБСП Цикл
				ПоддерживаемыеВерсии.Добавить(ЭлементВерсииФормата.Ключ);
			КонецЦикла;
			
			ПланОбменаСсылка = ПолучитьЭлементСтруктурыМетаданных(ВерсияКонфигурации,, ИмяПланаОбмена,
				Перечисления.ТипыОбъектов.ПланОбмена);
			
			Если ПланОбменаСсылка.Пустая() Тогда
				Продолжить;
			КонецЕсли;
			
			НоваяСтрока = ТаблицаВерсийФорматаОбмена.Добавить();
			НоваяСтрока.ПланОбмена = ПланОбменаСсылка;
			НоваяСтрока.ВерсииФорматаОбмена = ПоддерживаемыеВерсии;
			
		Исключение
			Продолжить;
		КонецПопытки;
		
	КонецЦикла;
	
	ЗавершитьCOMСоединениеСБазой(ТекущаяБаза);
	
	Возврат ТаблицаВерсийФорматаОбмена;
	
КонецФункции

#КонецОбласти