-- В БД есть две таблицы: 
-- collaborators - таблица сотрудников. Поля: id, name (имя сотрудника), subdivision_id (id подразделения сотрудника), age (возраст).
-- subdivisions - таблица подразделений. Поля: id, name, parent_id (id родительского подразделения)

DECLARE @starting_subdiv INT;

SELECT @starting_subdiv=[subdivision_id]
    FROM collaborators 
    WHERE id=710253;

-- Использем рекрсию, потому что вложенность департаментов обычно невелика (<100)
WITH cte (id, name, parent_id, sub_level) 
AS (

    SELECT 
-- считаю уровень вложенности департаметов начиная с нуля, @starting_subdiv — нулевой
        id, name, parent_id, 1
    FROM
        subdivisions
    WHERE parent_id=@starting_subdiv
    UNION ALL
    SELECT    
       s.id, s.name, s.parent_id, sub_level+1
    FROM 
        subdivisions s
        INNER JOIN cte d
            ON d.id = s.parent_id
)

SELECT 
    c.id, 
    c.name,
    d.name AS sub_name,
    d.id AS sub_id, 
    d.sub_level,
    COUNT(c.id) OVER (PARTITION BY d.id) AS colls_count
FROM 
    collaborators c
    INNER JOIN cte d
        ON c.subdivision_id = d.id 
            AND d.id NOT IN (100055, 100059)
WHERE
    LEN(c.name) > 11 
    AND c.age < 40 
ORDER BY d.sub_level ASC 
