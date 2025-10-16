WITH tb_transacao AS (

SELECT *,
         substr(DtCriacao,0,11) as dtDia
FROM transacoes
WHERE DtCriacao < '2025-10-01'
),

tb_agg_transacao AS (
SELECT idCliente,
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
        sum(DISTINCT CASE WHEN dtDia > date ('2025-10-01', '-56 day') AND qtdePontos > 0 THEN qtdePontos else 0 END) AS qtdePontosNegD56

FROM tb_transacao

GROUP BY idCliente

)

SELECT 
        *,
 coalesce(1. * qtdeAtivacaoVida / qtdeTransacaoVida,0) AS qtdeTransacaoDiaVida,
 coalesce(1. * qtdeTransacaoD7  / qtdeAtivacaoD7,0)  AS qtdeTransacaoDiaD7, 
 coalesce(1. * qtdeTransacaoD14 / qtdeAtivacaoD14,0) AS qtdeTransacaoDiaD14,
 coalesce(1. * qtdeTransacaoD28 / qtdeAtivacaoD28,0) AS qtdeTransacaoDiaD28,
 coalesce(1. * qtdeTransacaoD56 / qtdeAtivacaoD56,0) AS qtdeTransacaoDiaD56,

coalesce(1. * qtdeAtivacaoD28 / 28,0) AS pcAtivacaoMau

FROM tb_agg_transacao
