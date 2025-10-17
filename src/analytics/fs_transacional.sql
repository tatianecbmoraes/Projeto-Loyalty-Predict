WITH tb_transacao AS (

SELECT *,
         substr(DtCriacao,0,11) as dtDia,
         cast(substr(DtCriacao, 12,2) as int) as dtHora

FROM transacoes
WHERE DtCriacao < '2025-10-01'
),

tb_agg_transacao AS (
SELECT idCliente,

        max(julianday('2025-10-01') - julianday (DtCriacao)) AS idadeDias,
        
        count(DISTINCT dtDia) AS qtdeAtivacaoVida,
        count(DISTINCT CASE WHEN dtDia > date ('2025-10-01', '-7 day') THEN dtDia END) AS qtdeAtivacaoD7,
        count(DISTINCT CASE WHEN dtDia > date ('2025-10-01', '-14 day') THEN dtDia END) AS qtdeAtivacaoD14,
        count(DISTINCT CASE WHEN dtDia > date ('2025-10-01', '-28 day') THEN dtDia END) AS qtdeAtivacaoD28,
        count(DISTINCT CASE WHEN dtDia > date ('2025-10-01', '-56 day') THEN dtDia END) AS qtdeAtivacaoD56,

        count(DISTINCT IdTransacao) AS qtdeTransacaoVida,
        count(DISTINCT CASE WHEN dtDia > date ('2025-10-01', '-7 day') THEN IdTransacao END) AS qtdeTransacaoD7,
        count(DISTINCT CASE WHEN dtDia > date ('2025-10-01', '-14 day') THEN IdTransacao  END) AS qtdeTransacaoD14,
        count(DISTINCT CASE WHEN dtDia > date ('2025-10-01', '-28 day') THEN IdTransacao  END) AS qtdeTransacaoD28,
        count(DISTINCT CASE WHEN dtDia > date ('2025-10-01', '-56 day') THEN IdTransacao  END) AS qtdeTransacaoD56,
    
        sum(qtdePontos) AS saldoVida,
        sum(DISTINCT CASE WHEN dtDia > date ('2025-10-01', '-7 day') THEN qtdePontos  else 0 END) AS saldoD7,
        sum(DISTINCT CASE WHEN dtDia > date ('2025-10-01', '-14 day') THEN qtdePontos else 0 END) AS saldoD14,
        sum(DISTINCT CASE WHEN dtDia > date ('2025-10-01', '-28 day') THEN qtdePontos else 0 END) AS saldoD28,
        sum(DISTINCT CASE WHEN dtDia > date ('2025-10-01', '-56 day') THEN qtdePontos else 0 END) AS saldoD56,

        sum(CASE WHEN qtdePontos > 0 THEN qtdePontos ELSE 0 END) AS qtPontosPosVida,
        sum(DISTINCT CASE WHEN dtDia > date ('2025-10-01', '-7 day')  AND qtdePontos > 0 THEN qtdePontos else 0 END) AS qtdePontosPosD7,
        sum(DISTINCT CASE WHEN dtDia > date ('2025-10-01', '-14 day') AND qtdePontos > 0 THEN qtdePontos else 0 END) AS qtdePontosPosD14,
        sum(DISTINCT CASE WHEN dtDia > date ('2025-10-01', '-28 day') AND qtdePontos > 0 THEN qtdePontos else 0 END) AS qtdePontosPosD28,
        sum(DISTINCT CASE WHEN dtDia > date ('2025-10-01', '-56 day') AND qtdePontos > 0 THEN qtdePontos else 0 END) AS qtdePontosPosD56,

        sum(CASE WHEN qtdePontos < 0 THEN qtdePontos ELSE 0 END) AS qtPontosNegVida,
        sum(DISTINCT CASE WHEN dtDia > date ('2025-10-01', '-7 day')  AND qtdePontos > 0 THEN qtdePontos else 0 END) AS qtdePontosNegD7,
        sum(DISTINCT CASE WHEN dtDia > date ('2025-10-01', '-14 day') AND qtdePontos > 0 THEN qtdePontos else 0 END) AS qtdePontosNegD14,
        sum(DISTINCT CASE WHEN dtDia > date ('2025-10-01', '-28 day') AND qtdePontos > 0 THEN qtdePontos else 0 END) AS qtdePontosNegD28,
        sum(DISTINCT CASE WHEN dtDia > date ('2025-10-01', '-56 day') AND qtdePontos > 0 THEN qtdePontos else 0 END) AS qtdePontosNegD56,

        1.* count(CASE WHEN dtHora BETWEEN 10 AND 14 THEN IdTransacao END) / count(IdTransacao) AS qtdeTransacaoManha,
        1.* count(CASE WHEN dtHora BETWEEN 15 AND 21 THEN IdTransacao END) / count(IdTransacao) AS qtdeTransacaoTarde,
        1.* count(CASE WHEN dtHora > 21 OR dtHora < 10 THEN IdTransacao END) / count(IdTransacao) AS qtdeTransacaoNoite


FROM tb_transacao

GROUP BY idCliente

),

tb_agg_calc AS (

SELECT 
        *,
 coalesce(1. * qtdeAtivacaoVida / qtdeTransacaoVida,0) AS qtdeTransacaoDiaVida,
 coalesce(1. * qtdeTransacaoD7 / qtdeAtivacaoD7,0)  AS qtdeTransacaoDiaD7, 
 coalesce(1. * qtdeTransacaoD14 / qtdeAtivacaoD14,0) AS qtdeTransacaoDiaD14,
 coalesce(1. * qtdeTransacaoD28 / qtdeAtivacaoD28,0) AS qtdeTransacaoDiaD28,
 coalesce(1. * qtdeTransacaoD56 / qtdeAtivacaoD56,0) AS qtdeTransacaoDiaD56,

coalesce(1. * qtdeAtivacaoD28 / 28,0) AS pcAtivacaoMau

FROM tb_agg_transacao
),

tb_horas_dia AS (

SELECT idCliente,
        dtDia,
        24 * (max(julianday(DtCriacao)) - min(julianday(DtCriacao))) AS duracao

FROM tb_transacao

GROUP BY idCliente, dtDia
),
tb_hora_cliente as (

SELECT idCliente,
       sum(duracao) AS qtdeHorasVida,
       sum(CASE WHEN dtDia >= date ('2025-10-01', '-7 day') THEN duracao ELSE 0 END) AS qtdeHorasD7,
       sum(CASE WHEN dtDia >= date ('2025-10-01', '-14 day') THEN duracao ELSE 0 END) AS qtdeHorasD14,
       sum(CASE WHEN dtDia >= date ('2025-10-01', '-28 day') THEN duracao ELSE 0 END) AS qtdeHorasD28,
       sum(CASE WHEN dtDia >= date ('2025-10-01', '-56 day') THEN duracao ELSE 0 END) AS qtdeHorasD56

FROM tb_horas_dia

GROUP BY idCliente
),

tb_lag_dia AS (

SELECT idCliente,
       dtDia,
       LAG(dtDia) OVER (PARTITION BY idCliente ORDER BY dtDia ) AS lagDia

FROM tb_horas_dia 
),

tb_intervalo_dias AS (

SELECT idCliente,
       avg(julianday(dtDia) - julianday(lagDia)) AS avgIntervaloDias,
       avg(CASE WHEN dtDia >= date('2025-10-01', '- 28day') THEN julianday(dtDia) - julianday(lagDia) END) AS avgIntervaloDias28

FROM tb_lag_dia

GROUP BY idCliente
),

tb_share_produtos AS (

SELECT idCliente,

        1.* count( CASE WHEN DescNomeProduto ='ChatMessage'THEN t1.IdTransacao END) / count(t1.IdTransacao) AS qtdeChatMessage,
        1.* count( CASE WHEN DescNomeProduto ='Lista de presença'THEN t1.IdTransacao END) / count(t1.IdTransacao) AS qtdeListadepresença,
        1.* count( CASE WHEN DescNomeProduto ='R Lover'THEN t1.IdTransacao END) / count(t1.IdTransacao) AS qtdeRLover,
        1.* count( CASE WHEN DescNomeProduto ='Resgatar Ponei'THEN t1.IdTransacao END) / count(t1.IdTransacao) AS qtdeResgataPonei,
        1.* count( CASE WHEN DescNomeProduto ='Airflow Lover'THEN t1.IdTransacao END) / count(t1.IdTransacao) AS qtdeAirflowLover,
        1.* count( CASE WHEN DescNomeProduto ='Presença Streak'THEN t1.IdTransacao END) / count(t1.IdTransacao) AS qtdePresencaStreak,
        1.* count( CASE WHEN DescNomeProduto ='Troca de Pontos StreamElements'THEN t1.IdTransacao END) / count(t1.IdTransacao) AS qtdeTrocaStreamElements,
        1.* count( CASE WHEN DescNomeProduto ='Reembolso: Troca de Pontos StreamElements'THEN t1.IdTransacao END) / count(t1.IdTransacao) AS qtdeReembolsoStreamElements,
        1.* count( CASE WHEN DescCategoriaProduto = 'rpg' then t1.IdTransacao END) / count(t1.IdTransacao) as qtdeRpg,
        1.* count( CASE WHEN DescCategoriaProduto = 'churn_model' then t1.IdTransacao END) / count(t1.IdTransacao) as qtdeChurnModel,

       t3.DescNomeProduto,
       t3.DescCategoriaProduto

FROM tb_transacao AS t1

LEFT JOIN transacao_produto as t2
ON t1.IdTransacao = t2.IdTransacao

LEFT JOIN produtos AS t3
ON t2.IdProduto = t3.IdProduto

GROUP BY idCliente
),

tb_join AS (
SELECT t1.*,
        t2.qtdeHorasVida,
        t2.qtdeHorasD7,
        t2.qtdeHorasD14,
        t2.qtdeHorasD28,
        t2.qtdeHorasD56,
        t3.avgIntervaloDias,
        t3.avgIntervaloDias28,
        t4.qtdeChatMessage,
        t4.qtdeListadepresença,
        t4.qtdeRLover,
        t4.qtdeResgataPonei,
        t4.qtdeAirflowLover,
        t4.qtdePresencaStreak,
        t4.qtdeTrocaStreamElements,
        t4.qtdeReembolsoStreamElements,
        t4.qtdeRpg,
        t4.qtdeChurnModel


        FROM tb_agg_calc as t1

        LEFT JOIN tb_hora_cliente as t2
        ON t1.idCliente = t2.idCliente

        LEFT JOIN tb_intervalo_dias  AS t3
        ON t1.idCliente = t3.idCliente

        LEFT JOIN tb_share_produtos AS t4
        ON t1.idCliente = t4.idCliente

)

SELECT * 
FROM tb_join