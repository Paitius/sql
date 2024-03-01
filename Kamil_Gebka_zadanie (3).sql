-- -- -------------------------------------------------------------------------------
-- -- Zadania
-- -- -------------------------------------------------------------------------------

-- -- -------------------------------------------------------------------------------
-- Section: setting sql_mode
-- -- -------------------------------------------------------------------------------
SET sql_mode = 'ONLY_FULL_GROUP_BY,STRICT_ALL_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';

--
-- Current Database: `wsb_db_zadania`
--

CREATE DATABASE /*!32312 IF NOT EXISTS*/ `wsb_db_zadania` /*!40100 DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci */ /*!80016 DEFAULT ENCRYPTION='N' */;


-- -- -------------------------------------------------------------------------------
-- Section: USE
-- -- -------------------------------------------------------------------------------
USE wsb_db_zadania;

-- -- -------------------------------------------------------------------------------
-- Section: rozwiązanie zadania
-- -- -------------------------------------------------------------------------------

-- 1. 	Wyświetl metale posortowane według gęstości malejąco.

SELECT m.metal_name, m.density 
FROM wsb_db_zadania.metal m
ORDER BY m.density DESC;

-- 2. 	Znajdź 10 najstarszych pracowników.

SELECT e.first_name, e.last_name, e.birth_date 
FROM wsb_db_zadania.employee e
ORDER BY e.birth_date ASC LIMIT 10;

-- 3. 	Wyświetl 10 pracowników z największym stażem pracy oraz ich staż w latach. Uwzględnij również nie pracujących już pracowników.

SELECT e.id, e.first_name, e.last_name, e.hire_date, e.termination_date, 
TIMESTAMPDIFF(YEAR, e.hire_date, IFNULL(e.termination_date, CURDATE())) AS years_of_service
FROM wsb_db_zadania.employee e
ORDER BY (TIMESTAMPDIFF(DAY, e.hire_date, IFNULL(e.termination_date, CURDATE()))) DESC
LIMIT 10;

-- Wyświetlamy lata pracy, ale sortujemy po dniach, ponieważ daty są podane co do dnia, tak więc staż może być liczony co do dnia

-- 4. 	Wyświetl imię pracownika, którzy pracował najkrócej w firmie.
SELECT e.first_name
FROM wsb_db_zadania.employee e
ORDER BY TIMESTAMPDIFF(DAY, e.hire_date, IFNULL(e.termination_date, CURDATE())) ASC
LIMIT 1;

-- W przypadku naszych danych nie ma różnicy w rozpatrywaniu między dniem, a rokiem, ponieważ otrzymany wynik jest taki sam, ale gdyby były dwie jednakowe wartości
-- otrzymany wynik bedzie niejednoznaczny 

-- 5. 	Znajdź pracownika, który był najstarszy w momencie zatrudnienia.

SELECT e.id, e.first_name, e.last_name, e.birth_date,e.hire_date
FROM wsb_db_zadania.employee e
ORDER BY (TIMESTAMPDIFF(DAY, e.birth_date, e.hire_date))  DESC
LIMIT 1;

-- W tym przypadku sortowanie po latach jest niejednoznaczne, tak więc większy sens ma sortowanie po dniach
-- daty są podane co do dnia, dlatego nie ma sensu rozpatrywać poniżej dokładności dnia 

-- 6. 	Znajdź metale, które nie są jeszcze przechowywane przez klientów.

SELECT m.metal_name
FROM wsb_db_zadania.metal m
LEFT JOIN wsb_db_zadania.storage s 
ON m.id = s.metal_id
WHERE s.metal_id is NULL;

-- 7. 	Wyświetl klientów, którzy nie mają przypisanych pracowników do przechowywanych metali.

SELECT *
FROM wsb_db_zadania.client c
LEFT JOIN wsb_db_zadania.storage s 
ON c.id = s.client_id
WHERE s.employee_id IS NULL;

-- 8. 	Znajdź pracowników z unikalnymi numerami dokumentów.

SELECT e.first_name, e.last_name
FROM wsb_db_zadania.employee e
JOIN (  SELECT e.document_id
		FROM wsb_db_zadania.employee e
		GROUP BY e.document_id
		HAVING COUNT(e.document_id) = 1) AS uniq_doc_id
ON e.document_id = uniq_doc_id.document_id;


-- 9. 	Znajdź klienta, którzy przechowuje metale o największej sumarycznej objętości.

SELECT c.id, c.name, c.surname, SUM(s.weight/m.density) AS volume
FROM wsb_db_zadania.client c
JOIN wsb_db_zadania.storage s
ON c.id = s.client_id
JOIN wsb_db_zadania.metal m
ON s.metal_id = m.id
GROUP BY client_id
ORDER BY volume DESC
LIMIT 1;

-- 10. 	Oblicz średnią gęstość metalu w mennicy i wybierz metale o gęstości powyżej tej średniej.

SELECT m.metal_name
FROM wsb_db_zadania.metal m
WHERE m.density > (SELECT AVG(density) AS avg_density
					FROM wsb_db_zadania.metal
);

-- 11. 	Znajdź pracowników, którzy obiekują się więcej niż dwoma klientami.

SELECT t1.id as employee_id
FROM( 	SELECT e.id, s.client_id AS client_id
		FROM wsb_db_zadania.employee e
		JOIN wsb_db_zadania.storage s 
		ON e.id = s.employee_id
		GROUP BY e.id, s.client_id) as t1
GROUP BY t1.id
HAVING COUNT(t1.client_id)>2;


-- 12. 	Wyświetl klientów, którzy przechowują metal o najmniejszej gęstości.

SELECT e.id, e.first_name, e.last_name, m.density
FROM wsb_db_zadania.employee e
JOIN wsb_db_zadania.storage s
ON e.id = s.client_id
JOIN wsb_db_zadania.metal m
ON s.metal_id = m.id
HAVING m.density = (SELECT MIN(m.density)
					FROM wsb_db_zadania.metal m);


-- 13. 	Policz liczbę unikalnych klientów, którzy mieli przechowywane metale pod opieką pracownika o określonym imieniu.
-- Jeśli jest więcej niż jeden pracownik o danym imieniu, policz dla każdego z osobno.

SELECT COUNT(DISTINCT client_id) AS uniq_nuber_client
FROM wsb_db_zadania.storage s
JOIN wsb_db_zadania.employee e
ON s.employee_id = e.id
WHERE e.first_name = "John";


-- 14. 	Znajdź metale, które były przechowywane przez co najmniej 3 różnych klientów.

SELECT m.metal_name
FROM wsb_db_zadania.storage s
JOIN wsb_db_zadania.metal m
ON s.metal_id = m.id
GROUP BY s.metal_id
HAVING COUNT(DISTINCT s.client_id) >= 3;

-- 15. 	Wybierz pracowników, którzy zostali zatrudnieni przed najstarszym klientem firmy.

-- zrozumiałem to tak, że trzeba wyświetlić pracowników, którzy zostali zatrudnieni przed pierwszym klientem (najstarszym)
-- pytanie czy uznajemy, że dana osoba zostaje klientem, kiedy zostana dodana do bazy clients (create_date), czy do bazy storage (create_date)
-- dlatego napisze obie wersje

-- zapytanie kiedy zostaje dodany do bazy client

SELECT e.first_name, e.last_name, e.hire_date
FROM wsb_db_zadania.employee e
WHERE e.hire_date <(SELECT c.create_date
					FROM wsb_db_zadania.client c
					ORDER BY c.create_date ASC
					LIMIT 1);

-- zapytanie kiedy uznajemy za najstarszego klienta wg daty dodania do bazy storage

SELECT e.first_name, e.last_name, e.hire_date
FROM wsb_db_zadania.employee e
WHERE e.hire_date <(SELECT s.create_date
					FROM wsb_db_zadania.storage s
					ORDER BY s.create_date ASC
					LIMIT 1);

-- w przypadku najstarszego klienta w rozumieniu jako wiek, brakuje danych, musielibyśmy mieć wiek klienta lub jego datę urodzenia

-- 16. 	Oblicz różnicę między średnią gęstością metalu, którymi są opiekunami klienta mężczyzni i kobiety.

SELECT (MAX(t1.avg_density) - MIN(t1.avg_density)) AS diff_avg_sex
FROM (SELECT e.sex, AVG(m.density) AS avg_density
	  FROM wsb_db_zadania.storage s
      JOIN wsb_db_zadania.employee e
      ON s.employee_id = e.id
      JOIN wsb_db_zadania.metal m
      ON s.metal_id = m.id
      GROUP BY e.sex) as t1;

-- 17. 	Znajdź klientów, którzy przechowują metale o gęstości zbliżonej do średniej gęstości wszystkich przechowywanych metali.

SELECT c.id, c.name, c.surname, AVG(m.density) AS avg_density_stored_by_client,
	(SELECT AVG(m.density) AS avg_stored_density
    FROM wsb_db_zadania.storage s
    JOIN wsb_db_zadania.metal m
    ON s.metal_id = m.id) AS avg_stored_density
FROM wsb_db_zadania.storage s
JOIN wsb_db_zadania.metal m
ON s.metal_id = m.id
JOIN wsb_db_zadania.client c
ON s.client_id = c.id
GROUP BY s.client_id
HAVING avg_density_stored_by_client BETWEEN avg_stored_density*0.9 AND avg_stored_density*1.1;

-- 18. 	Oblicz różnicę między największą a najmniejszą gęstością metalu którym opiekuje się pracownik.

SELECT s.employee_id, (MAX(m.density)-MIN(m.density)) AS density_diff_between_max_min
FROM wsb_db_zadania.storage s
JOIN wsb_db_zadania.metal m
ON s.metal_id = m.id
GROUP BY s.employee_id;

-- 19. 	Wyświetl pracowników który opiekują się największą ilością metali (co do wagi) dla każdego roku zatrudnienia osobno. Pomiń pracowników, którzy już nie pracują.



WITH sub_tab (emp_id, hire_year, max_weight) AS(
	SELECT s.employee_id, t1.hire_year, SUM(s.weight)
	FROM wsb_db_zadania.storage s
	JOIN (	SELECT e.id,YEAR(e.hire_date) AS hire_year
			FROM wsb_db_zadania.employee e
			WHERE e.termination_date IS NULL) as t1
	ON s.employee_id = t1.id
	GROUP BY s.employee_id, t1.hire_year)

SELECT st1.hire_year, st1.max_weight, st1.emp_id
FROM sub_tab st1
WHERE (hire_year, max_weight) IN ( SELECT hire_year, MAX(max_weight) AS maxweight
								   FROM sub_tab st2
                                   WHERE st1.hire_year = st2.hire_year
                                   GROUP BY hire_year);

-- 20. 	Znajdź metale, które były przechowywane przez wszystkich klientów w firmie.

SELECT m.metal_name
FROM wsb_db_zadania.storage s
JOIN wsb_db_zadania.metal m
ON s.metal_id = m.id
GROUP BY s.metal_id
HAVING COUNT(s.metal_id) = (
	SELECT COUNT(e.id)
    FROM wsb_db_zadania.employee e
    );

-- 21. 	Znajdź klientów, którzy przechowują metale pod opieką pracownika o największej liczbie przechowywanych metali.

SELECT DISTINCT c.name, c.surname
FROM wsb_db_zadania.storage s
JOIN wsb_db_zadania.client c
ON s.client_id = c.id
WHERE s.employee_id = ( SELECT s.employee_id
						FROM wsb_db_zadania.storage s
						GROUP BY s.employee_id
                        ORDER BY COUNT(s.metal_id) DESC
                        LIMIT 1);


-- 22. 	Oblicz różnicę między liczbą klientów przechowujących metale a liczbą pracowników odpowiedzialnych za przechowywanie tych metali.

SELECT DISTINCT ABS(COUNT(s.client_id) -
	(SELECT COUNT(e.id)
	FROM wsb_db_zadania.employee e
	WHERE e.termination_date IS NULL))
    AS diff_between_clients_stored_and_employee
FROM wsb_db_zadania.storage s;

-- 23. 	Znajdź pracownika, który przechowuje największą liczbę różnych rodzajów metali dla tego samego klienta.

SELECT s.employee_id, s.client_id, COUNT(DISTINCT s.metal_id) AS uniq_metal
FROM wsb_db_zadania.storage s
JOIN wsb_db_zadania.employee e
ON s.employee_id = e.id
GROUP BY employee_id, client_id
ORDER BY uniq_metal DESC
LIMIT 1;



	