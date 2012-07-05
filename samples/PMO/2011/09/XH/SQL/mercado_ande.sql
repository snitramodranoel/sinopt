SELECT
m.CodSubsistema,
Data,
CodPatamar,
SUM(m.Valor*pc.Valor) AS Valor

FROM
Mercado m,
PatamarCarga pc

WHERE
m.CodSubsistema = pc.CodSubsistema AND
DataIni = Data AND 
Estagio = 0 AND
m.Tpd_Id IN (11,13)

GROUP BY 
m.CodSubsistema, 
Data, 
CodPatamar

ORDER BY 
m.CodSubsistema, 
Data, 
CodPatamar
