--Celem projektu jest stworzenie systemu bazodanowego do reprezentowania struktury geograficznej œwiata w formie hierarchicznej oraz 
--implementacja funkcji umo¿liwiaj¹cych manipulacjê tymi danymi.

INSERT INTO Œwiat VALUES ('œwiat', '/'), ('Europa', '/1/'),('Afryka', '/2/'), 
('Niemcy', '/1/1/'), ('Grecja', '/1/2/'), ('Egipt', '/2/1/'), ('Kenia', '/2/2/'), 
('Berlin', '/1/1/1/'), ('Hamburg', '/1/1/2/'),('Ateny', '/1/2/1/'), ('Saloniki', '/1/2/2/'), ('Kair', '/2/1/1/'), ('Giza', '/2/1/2/'), ('Nairobi','/2/2/1/'), ('Mombasa', '/2/2/2/'),
('RosenstraBe', '/1/1/1/1/'),('Sperlingsgasse', '/1/1/1/2/'), ('Alterwall', '/1/1/2/1/'), ('Kratinou', '/1/2/1/1/'), ('Proxenon', '/1/2/2/1/'), ('AlFalki', '/2/1/1/1/'), ('Alaish', '/2/1/2/1/'), ('KundaSt','/2/2/1/1/'), (' Tanast', '/2/2/2/1/')

select * from Œwiat


-- a) wyœwietliæ ca³¹ jedn¹ (wybran¹) ga³¹Ÿ drzewa (od Œwiata do ulicy)
-- b) dodaæ nowy kraj
-- c) wyœwietliæ nazwê kontynentu na którym le¿y miasto 'x'
-- d) wyœwietliæ nazwy wszystkich krajów
-- e) sprawdziæ czy kraj 'x' le¿y na kontynencie 'y'
-- f) czy 'x' oraz 'y' s¹ krajami
-- g) wyœwietliæ wszystkie ulice miasta 'x'

-- a)

SELECT nazwa, poziom.ToString() AS Poziom
FROM Œwiat
WHERE poziom >= '/1/' AND poziom <= '/1/1/1/1/'

-- b)

INSERT INTO Œwiat (nazwa, poziom)
VALUES ('Hiszpania', '/1/3/')

-- c)

SELECT nazwa
FROM Œwiat
WHERE poziom = (
    SELECT poziom.GetAncestor(2)
    FROM Œwiat
    WHERE nazwa = 'x'
)

-- d)

SELECT DISTINCT nazwa
FROM Œwiat
WHERE poziom.GetLevel() = 2

-- e)

DECLARE @kraj hierarchyid, @kontynent hierarchyid
SELECT @kraj = poziom FROM Œwiat WHERE nazwa = 'x'
SELECT @kontynent = poziom FROM Œwiat WHERE nazwa = 'y'

SELECT CASE WHEN @kraj.IsDescendantOf(@kontynent) = 1 THEN 'TAK' ELSE 'NIE' END AS czy_na_kontynencie

-- f)

SELECT DISTINCT nazwa
FROM Œwiat
WHERE poziom.GetLevel() = 2 AND nazwa IN ('x', 'y')

-- jeœli  x lub y jest krajem zostanie zwrócona nazwa kraju

-- g)

SELECT nazwa FROM Œwiat WHERE poziom.GetLevel() = 4 AND poziom.GetAncestor(1) = (SELECT poziom FROM Œwiat WHERE nazwa = 'x')