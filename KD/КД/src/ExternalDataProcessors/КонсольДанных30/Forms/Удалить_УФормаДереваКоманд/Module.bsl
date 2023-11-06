#Область СОБЫТИЯ_ФОРМЫ

&НаКлиенте
Процедура ПередЗакрытием(Отказ, ЗавершениеРаботы, ТекстПредупреждения, СтандартнаяОбработка)
	ВладелецФормы.АдресКоманд = АдресСтруктурыКоманд;
	ВладелецФормы.ВыполнитьВыбраннуюКоманду(Неопределено);
КонецПроцедуры

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	//Получить дерево команд от владельца
	//Ключи = "ВстроенныеКоманды,ДеревоКоманд,КаталогСохраненияКоманд,СохранённыеКоманды"
	СтруктураКоманд = ПолучитьИзВременногоХранилища(Параметры.АдресКоманд);
	ЗначениеВРеквизитФормы(СтруктураКоманд.ДеревоКоманд, "ДеревоКоманд");
	АдресСтруктурыКоманд = ПоместитьВоВременноеХранилище(СтруктураКоманд, УникальныйИдентификатор);//Параметры.АдресКоманд;
	КаталогСохраненияКоманд = СтруктураКоманд.КаталогСохраненияКоманд;
КонецПроцедуры

#КонецОбласти 

#Область КОМАНДЫ
	
&НаКлиенте
Процедура ВыполнитьКоманду(Команда)
	//Если нет подчинённых строк, это команда и её надо выполнить.
	ТекИД = Элементы.ДеревоКоманд.ТекущаяСтрока;
	Если ТекИД <> Неопределено Тогда
		ТекКМД = ДеревоКоманд.НайтиПоИдентификатору(ТекИД);
		Если ТекКМД <> Неопределено Тогда
			Если ТекКМД.ПолучитьЭлементы().Количество() = 0 Тогда
				Закрыть(Новый Структура("Адрес,ИмяКоманды", АдресСтруктурыКоманд, ТекКМД.Имя));
			КонецЕсли;
		КонецЕсли;
	КонецЕсли; 
КонецПроцедуры

&НаКлиенте
Процедура ДобавитьИзменить(Команда)
	ТекИД = Элементы.ДеревоКоманд.ТекущаяСтрока;
	Если ТекИД <> Неопределено Тогда
		СтрокаДерева = ДеревоКоманд.НайтиПоИдентификатору(ТекИД);
	КонецЕсли;
	ЭтоКорень = СтрокаДерева.ПолучитьРодителя() = Неопределено;
	СтруктураФлагов = ВладелецФормы.ЧтоСохранятьВКоманде();
	СтруктураФлагов.Вставить("ИмяКоманды", СтрокаДерева.Имя + "_1");
	СтруктураФлагов.Вставить("Представление", "!_" + СтрокаДерева.Команда + "_!");
	СтруктураФлагов.Вставить("ПутьККоманде", ?(ЭтоКорень, "#КОРЕНЬ", СтрокаДерева.ПолучитьРодителя().Имя) + "$$$" + ТекИД);
	СтруктураФлагов.Вставить("ПутьККартинке", СтрокаДерева.Имя + "_1");
	СтруктураФлагов.Вставить("ЗакрыватьПриВыборе", Истина);
	СтруктураФлагов.Вставить("ЗакрыватьПриЗакрытииВладельца", Истина);
	СтруктураФлагов.Вставить("ТолькоПросмотр", Ложь);
	ОткрытьФорму("ВнешняяОбработка.КонсольДанных30.Форма.УФормаСохраненияКоманды",
	        СтруктураФлагов, Это(), Это());
КонецПроцедуры

&НаКлиенте
Процедура УдалитьКоманду(Команда)
	ТекИД = Элементы.ДеревоКоманд.ТекущаяСтрока;
	Если ТекИД <> Неопределено Тогда
		СтрокаДерева = ДеревоКоманд.НайтиПоИдентификатору(ТекИД);
		Если ЕстьВСтруктуреКоманд(СтрокаДерева.Имя) Тогда
			ПоказатьВопрос(Новый ОписаниеОповещения("ПродолжитьУдалениеКоманды", Это() , Новый Структура("СтрокаДерева,ТекИД", СтрокаДерева,ТекИД)),
					"Точно удалить команду? Это необратимо!",
					РежимДиалогаВопрос.ДаНет,,
					КодВозвратаДиалога.Нет, "Удалить?");
		Иначе
			Сообщить("Команда будет удалена только до обновления дерева!");
			СтрокаДерева.ПолучитьРодителя().ПолучитьЭлементы().Удалить(ТекИД);
		КонецЕсли; 
	КонецЕсли; 
КонецПроцедуры

#КонецОбласти 

#Область ПРОДОЛЖЕНИЯ_КОМАНД

// Продолжает удаление команды после вопроса
// Параметры:
//  Результат  - КодВозвратаДиалога - Результат обрабочика
//  СтруктураПараметров  - Структура - Параметры, переданные из обрабочика
&НаКлиенте
Процедура ПродолжитьУдалениеКоманды(Результат, СтруктураПараметров = Неопределено) Экспорт
	Если Результат = КодВозвратаДиалога.Да Тогда
		ТекИмя = СтруктураПараметров.СтрокаДерева.Имя;
		СтруктураПараметров.СтрокаДерева.ПолучитьРодителя().ПолучитьЭлементы().Удалить(СтруктураПараметров.ТекИД);
		УдалитьСК(ТекИмя);
		//СохранённыеКоманды.Удалить(ТекИмя);
		УдалитьФайлы(КаталогСохраненияКоманд + "\ТД" + ТекИмя + ".mxl");
		УдалитьФайлы(КаталогСохраненияКоманд + "\СодержимоеКоманды" + ТекИмя + ".сдр");
		ЗаписатьСКвФайл();
	КонецЕсли; 
КонецПроцедуры // ПродолжитьУдалениеКоманды

#КонецОбласти 
		
	
#Область СЛУЖЕБНЫЕ

// Удалет ключ из структуры сохранённых команд
// Параметры:
//  Ключ  - Строка - Ключ удаляемой команды
&НаСервере
Процедура УдалитьСК(Ключ)
	СтруктураКоманд = ПолучитьИзВременногоХранилища(АдресСтруктурыКоманд);
	Если СтруктураКоманд.СохранённыеКоманды.Свойство(Ключ) Тогда
		СтруктураКоманд.СохранённыеКоманды.Удалить(Ключ);
		ПоместитьВоВременноеХранилище(СтруктураКоманд, АдресСтруктурыКоманд);
	КонецЕсли;
КонецПроцедуры // УдалитьСК

// Возвращает эту форму
// Возвращаемое значение:
//   Управляемая форма   - Эта форма
&НаКлиенте
Функция Это()
	Возврат Вычислить(?(ВладелецФормы.ИспользоватьЭтаФорма, "ЭтаФорма", "ЭтотОбъект"))
КонецФункции // Это

// Записывает сохранённые команды в файл
&НаКлиенте
Процедура ЗаписатьСКвФайл()
	ТекстКЗаписи = ТекстСК(ВладелецФормы.Объект.Удалить_ТекстКода, ВладелецФормы.Объект.Удалить_ТекстЗапроса);
	ТекстДок = Новый ТекстовыйДокумент;
	ТекстДок.УстановитьТекст(ТекстКЗаписи);
	ТекстДок.НачатьЗапись(, КаталогСохраненияКоманд + "\СохранённыеКоманды.кмд");
КонецПроцедуры // ЗаписатьСКвФайл

&НаСервере
Функция ТекстСК(ТекстКодаП = "", ТекстЗапросаП = "") Экспорт
	СохранённыеКоманды = ПолучитьИзВременногоХранилища(АдресСтруктурыКоманд).СохранённыеКоманды;
	ТекстКЗаписи = "";
	Для каждого КиЗ Из СохранённыеКоманды Цикл
		ТекКоманда = КиЗ.Значение;
		//Если ТекКоманда.Модифицирован Тогда
			ТекстКЗаписи = ТекстКЗаписи + "#Имя =" + КиЗ.Ключ + Символы.ПС + "#Крт =" + ТекКоманда.Картинка + Символы.ПС
					+ "#Путь=" + ТекКоманда.Путь + Символы.ПС;
			Если ТекКоманда.ТекстКода <> "" Тогда
				ТекстКода = ТекстКодаП;
				ТекстКЗаписи = ТекстКЗаписи + "#ТКод=" + СтрЧислоСтрок(ТекстКода) + Символы.ПС + ТекстКода + Символы.ПС;
			КонецЕсли; 
			Если ТекКоманда.ТекстЗапроса <> "" Тогда
				ТекстЗапроса = ТекстЗапросаП;
				ТекстКЗаписи = ТекстКЗаписи + "#ТЗпр=" + СтрЧислоСтрок(ТекстЗапроса) + Символы.ПС + ТекстЗапроса + Символы.ПС;
			КонецЕсли; 
			Если ТекКоманда.Представление <> "" Тогда
				ТекстКЗаписи = ТекстКЗаписи + "#Прст=" + ТекКоманда.Представление + Символы.ПС;
			КонецЕсли; 
			Если ТекКоманда.МВТ <> "" Тогда
				ТекстКЗаписи = ТекстКЗаписи + "#МВТ =+" + Символы.ПС;
			КонецЕсли; 
			Если ТекКоманда.СКД <> "" Тогда
				ТекстКЗаписи = ТекстКЗаписи + "#СКД =+" + Символы.ПС;
			КонецЕсли; 
			Если ТекКоманда.Предмет <> "" Тогда
				ТекстКЗаписи = ТекстКЗаписи + "#Прдм =+" + Символы.ПС;
			КонецЕсли; 
			Если ТекКоманда.Таб1 <> "" Тогда
				ТекстКЗаписи = ТекстКЗаписи + "#Таб1 =+" + Символы.ПС;
			КонецЕсли; 
			Если ТекКоманда.Таб2 <> "" Тогда
				ТекстКЗаписи = ТекстКЗаписи + "#Таб2 =+" + Символы.ПС;
			КонецЕсли; 
			Если ТекКоманда.ТД <> "" Тогда
				ТекстКЗаписи = ТекстКЗаписи + "#ТД  =+" + Символы.ПС;
			КонецЕсли; 
			Если ТекКоманда.Параметры <> "" Тогда
				ТекстКЗаписи = ТекстКЗаписи + "#Прм =+" + Символы.ПС;
			КонецЕсли;
		//КонецЕсли; 
	КонецЦикла; 
	Возврат ТекстКЗаписи
КонецФункции // 

// Собирает и записывает новую сохранённую команду
// Параметры:
//  Все из элементов вызывающей формы  - Булево, строка - Параметры сохраняемой команды
&НаКлиенте
Процедура ЗаписатьНовуюСК(ИмяКоманды, Представление, ПутьККоманде, ПутьККартинке, СохранитьТекстКода, СохранитьТекстЗапроса, СохранитьПредмет, СохранитьПараметры,
		СохранитьМВТ, СохранитьСКД, СохранитьТаб1, СохранитьТаб2, СохранитьТД) Экспорт
	ВставитьСКВСтруктуру(ИмяКоманды, Представление, ПутьККоманде, ПутьККартинке, ?(СохранитьТекстКода, ВладелецФормы.Объект.Удалить_ТекстКода, ""),
	        ?(СохранитьТекстЗапроса, ВладелецФормы.Объект.ТекстЗапроса, ""), СохранитьПредмет, СохранитьПараметры,
			СохранитьМВТ, СохранитьСКД, СохранитьТаб1, СохранитьТаб2, СохранитьТД);	
		
	#Область ЗАПИСЬ
		ЗаписатьСКвФайл();
		СохранитьРеквизитыБезТД = СохранитьМВТ ИЛИ СохранитьСКД ИЛИ СохранитьПредмет ИЛИ СохранитьТаб1 ИЛИ СохранитьТаб2 ИЛИ СохранитьПараметры;
		Если СохранитьРеквизитыБезТД ИЛИ СохранитьТД Тогда
			ФСтрССК = ВладелецФормы.ФССохраненияКоманды(СохранитьМВТ, СохранитьСКД, СохранитьПредмет, СохранитьТаб1, СохранитьТаб2, СохранитьПараметры, СохранитьТД);
			Если СохранитьРеквизитыБезТД Тогда
				ТекстДок = Новый ТекстовыйДокумент;
				ТекстДок.УстановитьТекст(ФСтрССК.РеквизитыБезТД);
				ТекстДок.НачатьЗапись(, ВладелецФормы.КаталогСохраненияКоманд + "\СодержимоеКоманды" + ИмяКоманды + ".сдр");
			ИначеЕсли СохранитьТД Тогда
				ФСтрССК.ТабДокумент.НачатьЗапись(, ВладелецФормы.КаталогСохраненияКоманд + "\ТД" + ИмяКоманды + ".mxl", ТипФайлаТабличногоДокумента.MXL);
			КонецЕсли;
		КонецЕсли; 
	#КонецОбласти 
	ПрочитатьДеревоКоманд();
КонецПроцедуры // ЗаписатьНовуюСК

&НаСервере
Процедура ВставитьСКВСтруктуру(ИмяКоманды, ПредставлениеКоманды, ПутьККоманде, ПутьККартинке, ТекстКода, ТекстЗапроса, СохранитьПредмет, СохранитьПараметры,
		СохранитьМВТ, СохранитьСКД, СохранитьТаб1, СохранитьТаб2, СохранитьТД)
	СКоманд = ПолучитьИзВременногоХранилища(АдресСтруктурыКоманд);
	СохранённыеКоманды = СКоманд.СохранённыеКоманды;
	СохранённыеКоманды.Вставить(ИмяКоманды, Новый Структура(РеквизитФормыВЗначение("Объект").ПоляСохранённойКоманды(),
			ИмяКоманды,
	        ПутьККоманде,
			ТекстКода,
			ТекстЗапроса,
	        ?(СохранитьМВТ, "+", ""),
	        ?(СохранитьСКД, "+", ""),
	        ?(СохранитьПредмет, "+", ""),
	        ?(СохранитьТаб1, "+", ""),
	        ?(СохранитьТаб2, "+", ""),
	        ?(СохранитьПараметры, "+", ""),
	        ?(СохранитьТД, "+", ""),
	        ПутьККартинке,
			ПредставлениеКоманды));
	ПоместитьВоВременноеХранилище(СКоманд, АдресСтруктурыКоманд);
КонецПроцедуры // ЗаписатьНовуюСК

// Возвращает наличие ключа в сохранённых командах
// Параметры:
//  ИмяКоманды  - Строка - Имя проверяемой команды
// Возвращаемое значение:
//   Булево   - Истина, если ключ есть
&НаСервере
Функция ЕстьВСтруктуреКоманд(ИмяКоманды, ВоВстроенных = Ложь)
	СтруктураКоманд = ПолучитьИзВременногоХранилища(АдресСтруктурыКоманд);
	ТекСтруктура = ?(ВоВстроенных, СтруктураКоманд.Удалить_ВстроенныеКоманды, СтруктураКоманд.СохранённыеКоманды);
	Возврат ТекСтруктура.Свойство(ИмяКоманды);
КонецФункции // ЕстьВСтруктуреКоманд
	
// КомандаЕстьВСК
// Параметры:
//  ИмяКоманды  - Строка - Проверяемое имя
// Возвращаемое значение:
//   Булево   - Команда есть в сохраняемых командах
&НаКлиенте
Функция КомандаЕстьВСК(ИмяКоманды) Экспорт
	Возврат КомандаЕстьВСКНаСервере(ИмяКоманды)
КонецФункции // КомандаЕстьВСК
 
// КомандаЕстьВСК
// Параметры:
//  ИмяКоманды  - Строка - Проверяемое имя
// Возвращаемое значение:
//   Булево   - Команда есть в сохраняемых командах
&НаСервере
Функция КомандаЕстьВСКНаСервере(ИмяКоманды)
	Возврат ПолучитьИзВременногоХранилища(АдресСтруктурыКоманд).СохранённыеКоманды.Свойство(ИмяКоманды);
КонецФункции // КомандаЕстьВСК
 
// Читает заново дерево команд
&НаСервере
Процедура ПрочитатьДеревоКоманд()
	Настоящий = РеквизитФормыВЗначение("Объект");
	СтруктураКоманд = ПолучитьИзВременногоХранилища(АдресСтруктурыКоманд);
	ЗаполнитьЗначенияСвойств(Настоящий, СтруктураКоманд);
	Настоящий.ПрочитатьДеревоКоманд("ДеревоКоманд");
	ЗаполнитьЗначенияСвойств(СтруктураКоманд, Настоящий);
	ЗначениеВРеквизитФормы(СтруктураКоманд.ДеревоКоманд, "ДеревоКоманд");
	ПоместитьВоВременноеХранилище(СтруктураКоманд, АдресСтруктурыКоманд);
КонецПроцедуры // ПрочитатьДеревоКоманд

#КонецОбласти 
