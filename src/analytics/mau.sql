 WITH tb_daily as( 
 SELECT DISTINCT
      date(substr(DtCriacao,01,11)) AS DtDia, 
       idCliente
 FROM transacoes
 ORDER BY DtDia

 ),
 tb_distinct_day AS (
 SELECT DISTINCT
     DtDia AS dtRef
 from tb_daily

 )

 SELECT t1.dtRef,
        count( DISTINCT idCliente) as MAU,
        count( DISTINCT t2.dtDia) as qtdeDias
 FROM tb_distinct_day AS t1

 LEFT JOIN tb_daily as t2
 ON t2.dtDia <=t1.dtRef
 AND julianday(t1.dtRef) - julianday (t2.dtDia) < 28

 GROUP BY t1.dtRef

 ORDER BY t1.dtRef ASC
