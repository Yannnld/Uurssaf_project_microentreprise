SELECT TOP (1000) [Type_de_travailleur_indépendant]
      ,[Région]
      ,[Ancienne_région]
      ,[Département]
      ,[Secteur_d_activité]
      ,[Année]
      ,[Code_région]
      ,[Code_ancienne_région]
      ,[Code_département]
      ,[Nombre_de_TI]
      ,[Revenu]
  FROM [urssaf_proj].[dbo].[les-revenus-des-travailleurs-independants-par-departement-secteur];


  SELECT 
  Type_de_travailleur_indépendant
  FROM [urssaf_proj].[dbo].[les-revenus-des-travailleurs-independants-par-departement-secteur]
  GROUP BY Type_de_travailleur_indépendant;


CREATE VIEW proj_urssaf AS 
WITH Revenue AS (
  SELECT 
  CASE 
    WHEN Secteur_d_activité LIKE 'QZ%'
    THEN 'QZ - Santé'
    ELSE Secteur_d_activité
  END AS Secteur_dac,
  Année,
  SUM(Nombre_de_TI) AS tt_nb, 
  SUM(Revenu) AS tt_revenue
  FROM [urssaf_proj].[dbo].[les-revenus-des-travailleurs-independants-par-departement-secteur]
  WHERE Type_de_travailleur_indépendant = 'Autoentrepreneur'
    AND Secteur_d_activité != '_calage_'
  GROUP BY CASE 
    WHEN Secteur_d_activité LIKE 'QZ%'
    THEN 'QZ - Santé'
    ELSE Secteur_d_activité
  END, Année
  --ORDER BY tt_revenue DESC; 
), 

Sales AS (
SELECT 
Secteur_d_activité, 
Année,
SUM(Chiffres_d_affaires) AS tt_sales
FROM [urssaf_proj].[dbo].[auto-entrepreneurs-par-secteur-dactivite]
GROUP BY Secteur_d_activité, Année
--ORDER BY tt_sales DESC; 
)

SELECT 
COALESCE (r.Secteur_dac, s.Secteur_d_activité) AS Business_Sector,
COALESCE (r.Année, s.Année) AS Annee,
r.tt_nb, 
s.tt_sales,
r.tt_revenue, 
ROUND(r.tt_revenue * 100 / s.tt_sales,2) AS pct_revenue, 
RANK () OVER (ORDER BY r.tt_revenue * 100 / s.tt_sales DESC) AS rk
FROM Revenue AS r 
LEFT JOIN Sales AS s 
    ON r.Secteur_dac = s.Secteur_d_activité
AND r.Année = s.Année
--ORDER BY rk; 
GO