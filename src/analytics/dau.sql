 SELECT substr(DtCriacao,01,11) AS DtDia, 
        count(DISTINCT idCliente) as DAU
 FROM transacoes
 GROUP by 1
 ORDER BY DtDia