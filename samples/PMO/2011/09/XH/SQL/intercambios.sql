SELECT
p.origem,
p.destino,
p.data,
p.codpatamar,
p.valor*i.int_valor AS valor

FROM
intercambios i,
patamarintercambio p

WHERE
estagio = 0 AND
p.data = i.int_dataini AND
p.origem = i.int_ssorigem AND
p.destino = i.int_ssdestino

ORDER BY
p.origem,
p.destino,
p.data,
p.codpatamar;
