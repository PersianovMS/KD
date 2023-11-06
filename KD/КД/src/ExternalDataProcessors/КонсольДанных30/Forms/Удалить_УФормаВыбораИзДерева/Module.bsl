&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	Настоящий = РеквизитФормыВЗначение("Объект");
	НазначениеРезультата = Параметры.НазначениеРезультата;
	Если Параметры.НазначениеРезультата = "ИзМодуля" Тогда
		НоваяДоска = Настоящий.ДеревоМетодовМодуля(Настоящий.ПолучитьМакет("ТекстМодуля").ПолучитьТекст());
		НоваяДоска.Колонки.Добавить("ТекстДляКода");
		НоваяДоска.Колонки.Добавить("ТекстДляЗапроса");
		НоваяДоска.Колонки.Представление.Имя = "Команда";
	ИначеЕсли (Параметры.НазначениеРезультата = "ТекстКода") ИЛИ (Параметры.НазначениеРезультата = "ТекстЗапроса") Тогда
		НоваяДоска = ПолучитьИзВременногоХранилища(Параметры.АдресДерева);
	ИначеЕсли (Параметры.НазначениеРезультата = "Директива") Тогда
		НоваяДоска = РеквизитФормыВЗначение("Дерево");
		ЭтиСтроки = НоваяДоска.Строки;
		НоваяСтрока = ЭтиСтроки.Добавить();
		НоваяСтрока.Команда = "Алгоритм";
		НоваяСтрока.ПолноеОписание = "&Алгоритм " + Символы.ПС;
		НоваяСтрока = ЭтиСтроки.Добавить();
		НоваяСтрока.Команда = "Вне формы на клиенте";
		НоваяСтрока.ПолноеОписание = "&Клиент " + Символы.ПС;
		НоваяСтрока = ЭтиСтроки.Добавить();
		НоваяСтрока.Команда = "ФормаНаКлиенте";
		НоваяСтрока.ПолноеОписание = "&Форма" + Символы.ПС;
		НоваяСтрока = ЭтиСтроки.Добавить();
		НоваяСтрока.Команда = "ФормаНаСервере";
		НоваяСтрока.ПолноеОписание = "&Сервер" + Символы.ПС;
		НоваяСтрока = ЭтиСтроки.Добавить();
		НоваяСтрока.Команда = "ВМодуле";
		НоваяСтрока.ПолноеОписание = "&Объект" + Символы.ПС;
	Иначе
		НоваяДоска = Новый ДеревоЗначений;
	КонецЕсли;
	АдресПолногоДерева = ПоместитьВоВременноеХранилище(НоваяДоска, УникальныйИдентификатор);
	ЗначениеВРеквизитФормы(НоваяДоска, "Дерево");
КонецПроцедуры

&НаКлиенте
Процедура СделатьВыбор(Команда)
	ОбработкаВыбора_();
КонецПроцедуры

&НаКлиенте
Процедура ДеревоВыборЗначения(Элемент, Значение, СтандартнаяОбработка)
	ОбработкаВыбора_()
КонецПроцедуры

&НаКлиенте
Процедура ОбработкаВыбора_() 
	ТекИД = Элементы.Дерево.ТекущаяСтрока;
	ТекСтрока = Дерево.НайтиПоИдентификатору(ТекИД);
	ВыборСделан = ТекСтрока.ПолучитьЭлементы().Количество() = 0;
	ЭтоМД = (НазначениеРезультата = "ТекстКода") ИЛИ (НазначениеРезультата = "ТекстЗапроса");
	Если ЭтоМД Тогда
		Если ВыборСделан Тогда
			//Не окончательно; возможно дополнение строки
			ТекВетка = ТекСтрока;
			Путь = "";
			Пока ТекВетка <> Неопределено Цикл
				Путь = Путь + Символы.ПС + ТекВетка.Команда;
				ТекВетка = ТекВетка.ПолучитьРодителя();
			КонецЦикла;
			СтрокиДМД = ПрочитатьМДсСервера(Путь, АдресПолногоДерева);
			Если СтрокиДМД <> Неопределено Тогда
				ВыборСделан = СтрокиДМД.Количество() = 0;
				КСтрок = ТекСтрока.ПолучитьЭлементы();
				Для каждого СтрокаМД Из СтрокиДМД Цикл
					ЗаполнитьЗначенияСвойств(КСтрок.Добавить(), СтрокаМД);
				КонецЦикла;
			КонецЕсли;
		Иначе
			ВыборСделан = Истина;
		КонецЕсли; 
	КонецЕсли;
	Если ВыборСделан Тогда
		Закрыть(Новый Структура("Текст,АдресДерева", ?(НазначениеРезультата = "ИзМодуля",
				ТекСтрока.ПолноеОписание,
				?(НазначениеРезультата = "ТекстКода",
				ТекСтрока.ТекстДляКода,
				?(НазначениеРезультата = "ТекстЗапроса",
				ТекСтрока.ТекстДляЗапроса,
				ТекСтрока.ПолноеОписание))), ?(ЭтоМД, АдресПолногоДерева, "")));
	Иначе
		Элементы.Дерево.Развернуть(ТекИД, Ложь);
	КонецЕсли; 
КонецПроцедуры

// Возвращаемое значение:
//   Коллекция строк дерева   - Прочитанные строки
&НаСервере
Функция ПрочитатьМДсСервера(Путь, АдресДерева)
	Дровина = ПолучитьИзВременногоХранилища(АдресДерева);
	Ветка = Дровина;
	КСтрок = СтрЧислоСтрок(Путь);
	Для Ё = 0 По КСтрок - 2 Цикл
		Ветка = Ветка.Строки.Найти(СтрПолучитьСтроку(Путь, КСтрок - Ё), "Команда");
		Если Ветка = Неопределено Тогда
			Возврат Неопределено
		КонецЕсли; 
	КонецЦикла;
	//Если Дровина.Строки.Количество() = 0 Тогда
		Дровина.Колонки.Команда.Имя = "Представление";
		Настоящий = РеквизитФормыВЗначение("Объект");
		Настоящий.ЗаполнитьДеревоМД(Ветка, Ветка.МД);
		Дровина.Колонки.Представление.Имя = "Команда";
	//КонецЕсли; 
	Результат = Новый Массив;
	Для каждого СтрокаМД Из Ветка.Строки Цикл
		ЛокРез = Новый Структура("Команда,ТекстДляКода,ТекстДляЗапроса");
		ЗаполнитьЗначенияСвойств(ЛокРез, СтрокаМД);
		Результат.Добавить(ЛокРез);
	КонецЦикла;
	ПоместитьВоВременноеХранилище(Дровина, АдресДерева);
	Возврат Результат
КонецФункции
 
