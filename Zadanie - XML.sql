--Projekt ma na celu utworzenie centralnej bazy danych dla zarz¹dzania zamówieniami sklepu internetowego,
--opartej na technologii Microsoft SQL Server. System ma na celu zorganizowanie, przechowywanie i przetwarzanie informacji o
--zamówieniach w formacie XML, co pozwala na elastyczne zarz¹dzanie struktur¹ danych oraz ³atw¹ modyfikacjê zawartoœci bez koniecznoœci 
--przeprojektowywania schematu bazy danych.

create database baza_pslomian
use baza_pslomian

create table zamowienia (id_zamowienia INT PRIMARY KEY IDENTITY, opis XML)

DECLARE @zamowienie_1 XML = '
<zamowienie>
    <data_zamowienia>2023-06-01</data_zamowienia>
    <klient>
        <imie>Katarzyna</imie>
        <nazwisko>Kowalska</nazwisko>
    </klient>
    <zawartosc>
        <produkt>
            <id>1</id>
            <nazwa>Koszulka polo</nazwa>
            <ilosc>2</ilosc>
            <cena>80</cena>
        </produkt>
        <produkt>
            <id>2</id>
            <nazwa>Spodnie cargo</nazwa>
            <ilosc>1</ilosc>
            <cena>200</cena>
        </produkt>
    </zawartosc>
    <wysylka>
        <miasto>Warszawa</miasto>
        <kod_pocztowy>92-456</kod_pocztowy>
        <ulica>Malinowa 5</ulica>
        <kraj>Polska</kraj>
    </wysylka>
    <paczka>
        <waga>15kg</waga>
        <wielkosc_przesylki>Du¿a</wielkosc_przesylki>
    </paczka>
	<dostawa>paczkomat</dostawa>
	<p³atnoœæ>p³atnoœæ przy odbiorze</p³atnoœæ>
</zamowienie>'

INSERT INTO zamowienia (opis) VALUES (@zamowienie_1)

DECLARE @zamowienie_2 XML = '
<zamowienie>
    <data_zamowienia>2023-06-01</data_zamowienia>
    <klient>
        <imie>Jan</imie>
        <nazwisko>Nowak</nazwisko>
    </klient>
    <zawartosc>
        <produkt>
            <id>3</id>
            <nazwa>Koszula</nazwa>
            <ilosc>1</ilosc>
            <cena>120</cena>
        </produkt>
    </zawartosc>
    <wysylka>
        <miasto>Kraków</miasto>
        <kod_pocztowy>30-456</kod_pocztowy>
        <ulica>¯wirowa 10</ulica>
        <kraj>Polska</kraj>
    </wysylka>
    <paczka>
        <waga>5kg</waga>
        <wielkosc_przesylki>Ma³a</wielkosc_przesylki>
    </paczka>
	<dostawa>kurier</dostawa>
	<p³atnoœæ>BLIK</p³atnoœæ>
</zamowienie>'

INSERT INTO zamowienia (opis) VALUES (@zamowienie_2)

DECLARE @zamowienie_3 XML = '
<zamowienie>
    <data_zamowienia>2023-06-02</data_zamowienia>
    <klient>
        <imie>Maciej</imie>
        <nazwisko>Kowalczyk</nazwisko>
    </klient>
    <zawartosc>
        <produkt>
            <id>4</id>
            <nazwa>Bluzka</nazwa>
            <ilosc>1</ilosc>
            <cena>90</cena>
        </produkt>
    </zawartosc>
    <wysylka>
        <miasto>Poznañ</miasto>
        <kod_pocztowy>61-789</kod_pocztowy>
        <ulica>Polna 15</ulica>
        <kraj>Polska</kraj>
    </wysylka>
    <paczka>
        <waga>2kg</waga>
        <wielkosc_przesylki>Ma³a</wielkosc_przesylki>
    </paczka>
	<dostawa>kurier</dostawa>
	<p³atnoœæ>p³atnoœæ przy odbiorze</p³atnoœæ>
</zamowienie>'

INSERT INTO zamowienia (opis) VALUES (@zamowienie_3)

-- wyœwietlenie dat z³o¿enia zamówieñ
SELECT
    opis.value('(zamowienie/data_zamowienia/text())[1]', 'DATE') AS data_zamowienia
FROM
    zamowienia;

--wyœwietlenie danych o zamawiaj¹cym

SELECT
    opis.value('(zamowienie/klient/imie)[1]', 'varchar(50)') AS imie,
    opis.value('(zamowienie/klient/nazwisko)[1]', 'varchar(50)') AS nazwisko
FROM
    zamowienia

--wyœwietlanie informacje o zawartoœci zamówienia 

SELECT zamowienia.id_zamowienia,
       zawartosc.produkt.value('(id)[1]', 'int') AS id_produktu,
       zawartosc.produkt.value('(nazwa)[1]', 'varchar(50)') AS nazwa_produktu,
       zawartosc.produkt.value('(ilosc)[1]', 'int') AS ilosc,
       zawartosc.produkt.value('(cena)[1]', 'decimal(10,2)') AS cena
FROM zamowienia
CROSS APPLY zamowienia.opis.nodes('/zamowienie/zawartosc/produkt') AS zawartosc(produkt)

--wyszukanie zamówienia wysy³anego do konkretnej lokalizacji (np. miasta)

SELECT zamowienia.id_zamowienia,
       zamowienia.opis.value('(/zamowienie/data_zamowienia)[1]', 'date') AS data_zamowienia,
       zamowienia.opis.value('(/zamowienie/wysylka/miasto)[1]', 'varchar(50)') AS miasto,
       zamowienia.opis.value('(/zamowienie/wysylka/kod_pocztowy)[1]', 'varchar(10)') AS kod_pocztowy,
       zamowienia.opis.value('(/zamowienie/wysylka/ulica)[1]', 'varchar(50)') AS ulica,
       zamowienia.opis.value('(/zamowienie/wysylka/kraj)[1]', 'varchar(50)') AS kraj
FROM zamowienia
WHERE zamowienia.opis.value('(/zamowienie/wysylka/miasto)[1]', 'varchar(50)') = 'Warszawa'

-- uzupe³nienie zamówienia o dodatkow¹ zawartoœæ

DECLARE @zamowienie_id INT = 1 

DECLARE @nowa_zawartosc XML = '
<produkt>
    <id>3</id>
    <nazwa>p³aszcz</nazwa>
    <ilosc>1</ilosc>
    <cena>50</cena>
</produkt>'

UPDATE zamowienia
SET opis.modify('insert sql:variable("@nowa_zawartosc") as last into (/zamowienie/zawartosc)[1]')
WHERE id_zamowienia = @zamowienie_id






