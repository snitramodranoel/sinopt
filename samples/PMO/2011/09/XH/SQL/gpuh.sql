SELECT
m.CodSubsistema,
pc.Data,
pc.CodPatamar,
m.Valor*pc.Valor AS Valor

FROM
GERACAOPCH m,
PatamarCarga pc

WHERE
m.CodSubsistema = pc.CodSubsistema AND
pc.Data = m.Data AND 
Estagio = 0

ORDER BY 
m.CodSubsistema, 
pc.Data, 
pc.CodPatamar;
