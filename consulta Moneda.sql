WITH DatosMoneda AS (

    SELECT 
        m.Id AS IdMoneda,
        m.Moneda,
        m.Sigla,

        (SELECT COUNT(*) 
         FROM Pais p 
         WHERE p.IdMoneda = m.Id) AS CantidadPaises,

        (SELECT MAX(c.Fecha)
         FROM CambioMoneda c
         WHERE c.IdMoneda = m.Id) AS FechaUltimoCambio,

        (SELECT TOP 1 c2.Cambio
         FROM CambioMoneda c2
         WHERE c2.IdMoneda = m.Id
         ORDER BY c2.Fecha DESC) AS ValorUltimoCambio,

        (SELECT AVG(c3.Cambio)
         FROM CambioMoneda c3
         WHERE c3.IdMoneda = m.Id
           AND c3.Fecha >= DATEADD(DAY, -30, GETDATE())
        ) AS Promedio30Dias,

        (SELECT 
            CASE 
                WHEN STDEV(c4.Cambio) < 0.05 THEN 'Baja'
                WHEN STDEV(c4.Cambio) BETWEEN 0.05 AND 0.15 THEN 'Media'
                ELSE 'Alta'
            END
         FROM CambioMoneda c4
         WHERE c4.IdMoneda = m.Id
         GROUP BY c4.IdMoneda
        ) AS Volatilidad

    FROM Moneda m
),

RankingMonedas AS (

    SELECT 
        d.*,
        RANK() OVER (ORDER BY d.CantidadPaises DESC) AS Ranking
    FROM DatosMoneda d
)

SELECT *
FROM RankingMonedas
ORDER BY Ranking;
