-- 1. Выбрать названия и цены за грамм корреспонденции, сумма измерений которых по длине, ширине и высоте превышает 30 см.

Select ct.type_name, sc.price_per_gram from correspondence_types ct join shipping_costs sc on ct.type_id = sc.type_id where (ct.max_length + ct.max_width + ct.max_height) > 30;

-- 2. Выбрать виды корреспонденции, где наценка за срочность больше 50% за отправку внутри страны.

Select ct.type_name 
from public.correspondence_types ct 
join public.shipping_costs sc on ct.type_id = sc.type_id 
where sc.urgency_markup > 50 and sc.distance = 'Городская'

-- 3. Создать таблицу, содержащую данные 2 запроса с указанием минимальных и максимальных размеров.
Select ct.type_name, ct.min_length, ct.max_length, ct.min_width, ct.max_width, ct.min_height, ct.max_height
Into urgent_sizes
From correspondence_types ct
Join shipping_costs sc ON ct.type_id = sc.type_id
Where sc.urgency_markup > 50 and sc.distance = 'Городская';

-- 4. Добавить в созданную таблицу виды корреспонденции, упаковывающиеся в коробки, максимальные размеры которых не указаны.
Insert into urgent_sizes (type_name, min_length, max_length, min_width, max_width, min_height, max_height)
Select type_name, min_length, max_length, min_width, max_width, min_height, max_height
from correspondence_types
Where packaging = 'Коробка' and (max_length is null or max_width is null or max_height is null);

-- 5. В созданной таблице у всех видов корреспонденции, соответствующих размерам формата A5 или меньше, изменить название на «Письмо».
Update urgent_sizes
Set type_name = 'Письмо'
Where max_length <= 21.0 and max_width <= 14.8;

-- 6. Удалить из созданной таблицы все виды корреспонденции, которые можно отправить только внутри страны.
Delete from urgent_sizes
Where type_name in (Select ct.type_name from correspondence_types ct where not exists (Select 1 from shipping_costs sc where sc.type_id = ct.type_id and sc.distance = 'Международная'));

-- 7. Посчитать средний вес и размеры для каждого наименования корреспонденции.
Select type_name as "Наименование", 
    ROUND((min_weight + max_weight) / 2.0, 1) as "Средний вес",
    ROUND((min_length + max_length) / 2.0, 1) as "Средняя длина",
    ROUND((min_width + max_width) / 2.0, 1) as "Средняя ширина",
    ROUND((min_height + max_height) / 2.0, 1) as "Средняя высота"
from correspondence_types
Group by type_name, min_weight, max_weight, min_length, max_length, min_width, max_width, min_height, max_height
Order by type_name;