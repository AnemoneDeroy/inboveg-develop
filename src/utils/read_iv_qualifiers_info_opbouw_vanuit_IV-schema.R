library(tidyverse)
library(DBI)
library(glue)
library(knitr)
library(odbc)
library(assertthat)
library(inborutils)

con <- connect_inbo_dbase("D0010_00_Cydonia")
con_futon <- connect_inbo_dbase("D0013_00_Futon")

## opbouw vanaf de queries uit AccessFront

# TEST <- 
# dbGetQuery(con, 
#   "SELECT RecordingGIVID.ivRecording
#           , ivRecording.UserReference
#           , ivRecording.Observer
#           , ivRLQualifier.QualifierType
#           , ivRLQualier.QualierCode
#           , qry_01ACvalues.oms 
#           , ivRLQualier_1.QualierCode
#           , qry_01ACvalues_1.oms
#           , ivRLQualier_2.QualierCode
#           , qry_01ACvalues_2.oms
#           , ivRLQualifier.Elucidation
#           , ivRLQualifier.NotSure
#           , ivRLQualier.ParentId
#  FROM ivRecording 
#  LEFT JOIN ivRLQualifier on Recording.ID = ivRecording.Id
#  LEFT JOIN ivRLQualifier AS ivRLQualifier_1 ON ivRLQualifier.ID = ivRLQualier_1.ParentID
#  LEFT JOIN ivRLQualifier AS ivRLQualifier_2 ON ivRLQualifier_1.ID = ivRLQualier_2.ParentID
# -- hier komt qry_01ACValues
#  LEFT JOIN (
#   SELECT
#     ivRLResources.ResourceGIVID
#     , ivRLResources.ActionGroup
#     , ivRLResources.ListName
#     , ftValues_union.Code
#     , ftValues_union.Description
#   FROM ivRLResources 
#   LEFT JOIN D0013_00_Futon.dbo.ftActionGroupList ON 
#     ivRLResources.ListName = D0013_00_Futon.dbo.ftActionGroupList.ListName collate Latin1_General_CI_AI
#   AND ivRLResources.ActionGroup = D0013_00_Futon.dbo.ftActionGroupList.ActionGroup collate Latin1_General_CI_AI

# -- hier begint de union van alle AC-value tabellen  
#   LEFT JOIN (

##############

# ) ftValues_union ON D0013_00_Futon.dbo.ftActionGroupList.ListGIVID = ftValues_union.ListGIVID
#         WHERE ivRLResources.ResourceGIVID LIKE 'RS2014091211335947'
# -- query AC - values
#   ) qry01_ACValues ON ivRLQualifier.QualifierCode = qry_01ACvalues.Code
#          AND ivRLQualifier.QualifierResource = qry_01ACvalues.ResourceGIVID 
#   LEFT JOIN qry_01ACvalues AS qry_01ACvalues_1 ON 
#         ivRLQualifier_1.QualifierCode = qry_01ACvalues_1.Code
#         AND ivRLQualifier_1.QualifierResource = qry_01ACvalues_1.ResourceGIVID 
#   LEFT JOIN qry_01ACvalues AS qry_01ACvalues_2 ON 
#   ivRLQualifier_2.QualifierCode = qry_01ACvalues_2.Code
#   AND ivRLQualifier_2.QualifierResource = qry_01ACvalues_2.ResourceGIVID
#   WHERE (((ivRLQualifier.ParentID) Is Null))
#   ORDER BY ivRecording.UserReference, ivRLQualifier.QualifierType, ivRLQualifier.QualifierCode;"
#   ,.con = con)

## testen van verschillede code mogelijkheden

library(tidyverse)
library(DBI)
library(glue)
library(knitr)
library(odbc)
library(assertthat)
library(inborutils)

#con <- connect_inbo_dbase("D0010_00_Cydonia")
con_futon <- connect_inbo_dbase("D0013_00_Futon")

## 3 aparte queries, achteraf mergen


## QUERY00 - UNION - WERKT
(x <- c(sort(sample(1:20, 9)), NA))
(y <- c(sort(sample(3:23, 7)), NA))
union(x, y)

order_by(10:1, cumsum(1:10))
x <- 10:1
y <- 1:10
order_by(x, cumsum(y))

?glue_sql

tbl_ftQV      <- tbl(con_futon, from = "ftQualifierValues")
tbl_ftDQV     <- tbl(con_futon, from = "ftDQualifierValues")
tbl_ftAbioV   <- tbl(con_futon, from = "ftAbiotiekValues")
tbl_ftBWKV    <- tbl(con_futon, from = "ftBWKValues")
tbl_ftCoverV  <- tbl(con_futon, from = "ftCoverValues")
tbl_ftFenoV   <- tbl(con_futon, from = "ftFenoValues")
tbl_ftGebiedV <- tbl(con_futon, from = "ftgebiedValues")
tbl_ftGHCV    <- tbl(con_futon, from = "ftGHCValues")
tbl_ftLayerV  <- tbl(con_futon, from = "ftLayerValues")
tbl_ftLFV     <- tbl(con_futon, from = "ftLFValues")
tbl_ftMngmtV  <- tbl(con_futon, from = "ftMngmtValues")
tbl_ftPatchV  <- tbl(con_futon, from = "ftPatchValues")
tbl_ftN2kV    <- tbl(con_futon, from = "ftN2kValues")
tbl_ftSociaV  <- tbl(con_futon, from = "ftSociaValues")
tbl_ftSoilV   <- tbl(con_futon, from = "ftSoilValues")
tbl_ftVitaV   <- tbl(con_futon, from = "ftVitaValues")


ftValues_union <- 
  union(tbl_ftQV
        , tbl_ftDQV
        , tbl_ftAbioV
        , tbl_ftBWKV
        , tbl_ftCoverV
        , tbl_ftFenoV
        , tbl_ftGebiedV
        , tbl_ftGHCV
        , tbl_ftLayerV
        , tbl_ftLFV
        , tbl_ftMngmtV
        , tbl_ftPatchV
        , tbl_ftN2kV
        , tbl_ftSociaV
        , tbl_ftSoilV
        , tbl_ftVitaV) %>% 
  select(Code, Description, ListGIVID) %>% 
  collect()
#show_query()


## RESULT:  
# Source:   lazy query [?? x 3]
# Database: Microsoft SQL Server 13.00.5216[INBO\els_debie@INBO-SQL07-PRD\LIVE/D0013_00_Futon]
# via collect () wordt ftValues_Uinon een tibble ...  A tibble: 2,247 x 3

## Kortere manier dan via union en alle tabellen apart in te lezen?

ftValues_union %>% show_query() #in plaats van collect()  # tip Hans
# <SQL>
#   SELECT "Code", "Description", "ListGIVID"
# FROM ((SELECT "ftQualifierValuesId", "ListGIVID", "Code", "Description", "Elucidation", "SortCode", NULL AS "ftDQualifierValuesId", NULL AS "DrillDownGIVID"
#        FROM "ftQualifierValues")
#       UNION
#       (SELECT NULL AS "ftQualifierValuesId", "ListGIVID", "Code", "Description", "Elucidation", "SortCode", "ftDQualifierValuesId", "DrillDownGIVID"
#         FROM "ftDQualifierValues")) "dbplyr_005"
# 

# Op basis van show_query nu de prd-sql omzetten... dit werkt!!
union_1 <- dbGetQuery(con_futon, 
                      "SELECT 
                      ftQValue_union.Code
                      , ftQValue_union.Description
                      , ftQValue_union.ListGIVID
                      FROM ((SELECT 
                      ftQValue.ftQualifierValuesId
                      , ftQValue.ListGIVID
                      , ftQValue.Code
                      , ftQValue.Description
                      , ftQValue.Elucidation
                      , ftQValue.SortCode
                      , NULL AS ftDQualifierValuesId
                      , NULL AS DrillDownGIVID
                      FROM ftQualifierValues ftQValue)
                      UNION(SELECT
                      NULL AS ftQualifierValuesId
                      , ftDQV.ListGIVID
                      , ftDQV.Code
                      , ftDQV.Description
                      , ftDQV.Elucidation
                      , ftDQV.SortCode
                      , ftDQV.ftDQualifierValuesId
                      , ftDQV.DrillDownGIVID
                      FROM ftDQualifierValues ftDQV))
                      AS ftQValue_union")

## nu verder uitbreiden met bijkomende tabellen, zelfde principe, 
# telkens een tabel erbij voegen 
union2 <- dbGetQuery(con_futon, "sELECT 
                     dbplyr_002.Code
                     , dbplyr_002.Description
                     , dbplyr_002.ListGIVID
                     FROM ((((SELECT 
                     ftQValue.ftQualifierValuesId
                     , ftQValue.ListGIVID
                     , ftQValue.Code
                     , ftQValue.Description
                     , ftQValue.Elucidation
                     , ftQValue.SortCode
                     , NULL AS ftDQualifierValuesId
                     , NULL AS DrillDownGIVID
                     FROM ftQualifierValues ftQValue)
                     UNION(SELECT
                     NULL AS ftQualifierValuesId
                     , ftDQV.ListGIVID
                     , ftDQV.Code
                     , ftDQV.Description
                     , ftDQV.Elucidation
                     , ftDQV.SortCode
                     , ftDQV.ftDQualifierValuesId
                     , ftDQV.DrillDownGIVID
                     FROM ftDQualifierValues ftDQV))AS dbplyr_001)
                     UNION ((SELECT
                     dbplyr_001.Code
                     , dbplyr_001.Description
                     , dbplyr_001.ListGIVID
                     FROM dbplyr_001)
                     , (SELECT
                     ftAbioV.ListGIVID
                     , ftAbioV.Code
                     , ftAbioV.Description
                     FROM ftAbiotiekValues ftAbioV))) as dbplyr_002")

# laatste regel zet alle unions in  $  AS ftQValue_union")  $

# Lukt niet ... 


## QUERY01 ACValues
qry_01ACvalues <- dbGetQuery(con,
                             "SELECT 
                             ivRLResources.ResourceGIVID
                             , ivRLResources.ActionGroup
                             , ivRLResources.ListName
                             , ftValues_union.Code
                             , ftValues_union.Description
                             FROM ivRLResources 
                             LEFT JOIN D0013_00_Futon.dbo.ftActionGroupList ON ivRLResources.ListName = D0013_00_Futon.dbo.ftActionGroupList.ListName collate Latin1_General_CI_AI
                             AND ivRLResources.ActionGroup = D0013_00_Futon.dbo.ftActionGroupList.ActionGroup collate Latin1_General_CI_AI
                             LEFT JOIN ftValues_union ON D0013_00_Futon.dbo.ftActionGroupList.ListGIVID = ftValues_union.ListGIVID
                             WHERE ivRLResources.ResourceGIVID LIKE 'RS2014091211335947' ")
## WHERE ftValues_union.ListGIVID LIKE 'FT2010120311482606' ")


qry_01ACvalues <- dbGetQuery(con,
                             "SELECT 
                             ivRLResources.ResourceGIVID
                             , D0013_00_Futon.dbo.ftActionGroupList.ListGIVID
                             , ivRLResources.ActionGroup
                             , ivRLResources.ListName
                             FROM ivRLResources 
                             LEFT JOIN D0013_00_Futon.dbo.ftActionGroupList ON ivRLResources.ListName = D0013_00_Futon.dbo.ftActionGroupList.ListName collate Latin1_General_CI_AI
                             AND ivRLResources.ActionGroup = D0013_00_Futon.dbo.ftActionGroupList.ActionGroup collate Latin1_General_CI_AI
                             ")
## WHERE ftValues_union.ListGIVID LIKE 'FT2010120311482606' ")

qry_01ACvalues %>% left_join(ftValues_union, by = c("ListGIVID" = "ListGIVID")) %>% View



## QUERY01 ACValues - CONNECTIE Futon
qry_01ACvalues <- dbGetQuery(con_futon,
                             "SELECT 
                             D0010_00_Cydonia.dbo.ivRLResources.ResourceGIVID
                             , D0010_00_Cydonia.dbo.ivRLResources.ActionGroup
                             , D0010_00_Cydonia.dbo.ivRLResources.ListName
                             , ftValues_union.Code
                             , ftValues_union.Description
                             FROM D0010_00_Cydonia.dbo.ivRLResources 
                             LEFT JOIN ftActionGroupList ON D0010_00_Cydonia.dbo.ivRLResources.ListName = ftActionGroupList.ListName collate Latin1_General_CI_AI
                             AND D0010_00_Cydonia.dbo.ivRLResources.ActionGroup = ftActionGroupList.ActionGroup collate Latin1_General_CI_AI
                             LEFT JOIN ftValues_union ON ftActionGroupList.ListGIVID = ftValues_union.ListGIVID
                             WHERE D0010_00_Cydonia.dbo.ivRLResources.ResourceGIVID LIKE 'RS2014091211335947' ")

## hoe kan ik verwijzen naar die eerste tibble? want daar geeft ie altijd foutmelding? 
# Error: <SQL> 'SELECT 
#        D0010_00_Cydonia.dbo.ivRLResources.ResourceGIVID
#      , D0010_00_Cydonia.dbo.ivRLResources.ActionGroup
#      , D0010_00_Cydonia.dbo.ivRLResources.ListName
#      , ftValues_union.Code
#      , ftValues_union.Description
#   FROM D0010_00_Cydonia.dbo.ivRLResources 
#   LEFT JOIN ftActionGroupList ON D0010_00_Cydonia.dbo.ivRLResources.ListName = ftActionGroupList.ListName collate Latin1_General_CI_AI
#   AND D0010_00_Cydonia.dbo.ivRLResources.ActionGroup = ftActionGroupList.ActionGroup collate Latin1_General_CI_AI
#   LEFT JOIN ftValues_union ON ftActionGroupList.ListGIVID = ftValues_union.ListGIVID
#   WHERE ivRLResources.ResourceGIVID LIKE 'RS2014091211335947' '
# nanodbc/nanodbc.cpp:1587: 42S02: [Microsoft][ODBC SQL Server Driver][SQL Server]Invalid object name 'ftValues_union'. 





## QUERY02 Alles verbinden MSQualifiers per opname
# als QUERY00 en 01 werken ... 
testje <- dbGetQuery(con,glue_sql(
  "SELECT 
  ivRecording.RecordingGivid
  , ivRecording.UserReference
  , ivRecording.Observer
  , ivRLQualifier.QualifierType
  , ivRLQualifier.QualifierCode
  , qry_01ACvalues.oms ## dit komt uit query01
  , ivRLQualifier_1.QualifierCode
  , qry_01ACvalues_1.oms  ## dit komt uit query01
  , ivRLQualifier_2.QualifierCode
  , qry_01ACvalues_2.oms  ## dit komt uit query01
  , ivRLQualifier.Elucidation
  , ivRLQualifier.NotSure
  , ivRLQualifier.ParentID
  FROM (((((ivRecording 
  LEFT JOIN ivRLQualifier ON ivRecording.Id = ivRLQualifier.RecordingID) 
  LEFT JOIN ivRLQualifier AS ivRLQualifier_1 ON 
  ivRLQualifier.ID = ivRLQualifier_1.ParentID) 
  LEFT JOIN ivRLQualifier AS ivRLQualifier_2 ON 
  ivRLQualifier_1.ID = ivRLQualifier_2.ParentID) 
  LEFT JOIN qry_01ACvalues ON (ivRLQualifier.QualifierCode = qry_01ACvalues.Code) 
  AND (ivRLQualifier.QualifierResource = qry_01ACvalues.ResourceGIVID)) 
  LEFT JOIN qry_01ACvalues AS qry_01ACvalues_1 ON 
  (ivRLQualifier_1.QualifierCode = qry_01ACvalues_1.Code) 
  AND (ivRLQualifier_1.QualifierResource = qry_01ACvalues_1.ResourceGIVID)) 
  LEFT JOIN qry_01ACvalues AS qry_01ACvalues_2 ON 
  (ivRLQualifier_2.QualifierCode = qry_01ACvalues_2.Code) 
  AND (ivRLQualifier_2.QualifierResource = qry_01ACvalues_2.ResourceGIVID)
  WHERE (((ivRLQualifier.ParentID) Is Null))
  ORDER BY ivRecording.UserReference, ivRLQualifier.QualifierType, ivRLQualifier.QualifierCode;"
  ,.con = con))


################### TESTEN

## uit prd-access van luc VH - Samenvoegquery

prd-query <- ("SELECT 
              ftQValue.Code
              , ftQValue.Description
              , ftQValue.ListGIVID
              FROM tbl_ftQValues ftQValue
              ORDER BY  ftQValue.ListGIVID
              , ftQValue.Code
              UNION(SELECT
              ftDQValue.Code
              , ftDQValue.Description
              , ftDQValue.ListGIVID as
              FROM ftDQualifierValues ftDQValue
              ORDER BY  ftDQValue.ListGIVID
              , ftDQValue.Code)
              UNION (SELECT
              ftAbioV.Code
              , ftAbioV.Description
              , ftAbioV.ListGIVID
              FROM ftAbiotiekValues ftAbioV
              ORDER BY  ftAbioV.ListGIVID
              , ftAbioV.Code)
              UNION (SELECT
              ftBWKV.Code  
              , ftBWKV.Description as oms
              , ftBWKV.ListGIVID 
              FROM D0013_00_Futon.dbo.ftBWKValues ftBWKV
              ORDER BY  ftBWKV.ListGIVID
              , ftBWKV.Code
              UNION (SELECT
              ftCoverV.Code
              , ftCoverV.PctValue as oms
              , ftCoverV.ListGIVID
              FROM D0013_00_Futon.dbo.ftCoverValues ftCoverV
              ORDER BY  ftCoverV.ListGIVID
              , ftCoverV.Code
              UNION (SELECT
              ftFenoV.Code
              , ftFenoV.Description as oms
              , ftFenoV.ListGIVID
              FROM D0013_00_Futon.dbo.ftFenoValues ftFenoV
              ORDER BY  ftFenoV.ListGIVID
              , ftFenoV.Code
              UNION (SELECT
              ftGebiedV.Code
              , ftGebiedV.Description as oms
              , ftGebiedV.ListGIVID 
              FROM D0013_00_Futon.dbo.ftgebiedValues ftGebiedV
              ORDER BY  ftGebiedV.ListGIVID
              ,ftGebiedV.Code)
              # UNION (SELECT
              #             ftGHCV.Code
              #             , ftGHCV."-" as oms
              #             , ftGHCV.ListGIVID
              #        FROM D0013_00_Futon.dbo.ftGHCValues ftGHCV
              #        ORDER BY  ftGHCV.ListGIVID
              #                , ftGHCV.Code)
              UNION (SELECT
              ftLayerV.Code
              , ftLayerV.Description as oms
              , ftLayerV.ListGIVID 
              FROM ftLayerValues ftLayerV
              ORDER BY  ftLayerV.ListGIVID
              , ftLayerV.Code)
              UNION (SELECT
              ftLFV.Code
              , ftLFV.Description as oms
              , ftLFV.ListGIVID
              FROM D0013_00_Futon.dbo.ftLFValues ftLFV
              ORDER BY  ftLFV.ListGIVID
              , ftLFV.Code
              UNION (SELECT
              ftMngmtV.Code
              , ftMngmtV.Description as oms
              , ftMngmtV.ListGIVID 
              FROM D0013_00_Futon.dbo.ftMngmtValues ftMngmtV
              ORDER BY  ftMngmtV.ListGIVID, ftMngmtV.Code)
              UNION (SELECT
              ftN2kV.Code
              , ftN2kV.Description as oms
              , ftN2kV.ListGIVID 
              FROM D0013_00_Futon.dbo.ftN2kValues ftN2kV
              ORDER BY  ftN2kV.ListGIVID
              , ftN2kV.Code)
              UNION (SELECT
              ftPatchV.Code
              , ftPatchV.Description as oms
              , ftPatchV.ListGIVID 
              FROM D0013_00_Futon.dbo.ftPatchValues ftPatchV
              ORDER BY  ftPatchV.ListGIVID
              , ftPatchV.Code)
              UNION (SELECT
              ftSociaV.Code
              , ftSociaV.Description as oms
              , ftSociaV.ListGIVID 
              FROM D0013_00_Futon.dbo.ftSociaValues ftSociaV
              ORDER BY  ftSociaV.ListGIVID
              , ftSociaV.Code)
              UNION (SELECT
              ftSoilV.Code
              , ftSoilV.Description as oms
              , ftSoilV.ListGIVID
              FROM D0013_00_Futon.dbo.ftSoilValues ftSoilV
              ORDER BY  ftSoilV.ListGIVID
              '    , ftSoilV.Code)
              UNION (SELECT
              ftVitaV.Code
              , ftVitaV.Description as oms
              , ftVitaV.ListGIVID
              FROM D0013_00_Futon.dbo.ftVitaValues ftVitaV
              ORDER BY ftVitaV.ListGIVID
              , ftVitaV.Code)")

## Lukt dit ook zonder eerst alle tbl's in te laden? NOPE
ftValues_union <- 
  union(ftQualifierValues
        , ftDQualifierValues
        , ftAbiotiekValues
        , ftBWKValues
        , ftCoverValues
        , ftFenoValues) %>% 
  select(Code, Description, ListGIVID)





## functie opbouwen 

inboveg_qualifiers <- function(connection,
                               survey_name,
                               collect = FALSE,
                               multiple = FALSE) {
  
  assert_that(inherits(connection, what = "Microsoft SQL Server"),
              msg = "Not a connection object to database.")
  
  if (missing(survey_name) & !multiple) {
    survey_name <- "%"
  }
  
  if (missing(survey_name) & multiple) {
    stop("Please provide one or more survey names to survey_name when multiple
         = TRUE")
  }
  
  if (!missing(survey_name)) {
    if (!multiple) {
      assert_that(is.character(survey_name))
    } else {
      assert_that(is.vector(survey_name, mode = "character"))
    }
  }
  
  common_part <- "SELECT 
  ivRecording.RecordingGivid
  , ivRecording.UserReference
  , ivRLHeadInfoD.MoistureCode
  , qry_01ACvalues_1.oms
  , ivRLHeadInfoD.GenHabCatCode
  , qry_01ACvalues.oms
  FROM (
  (ivRLHeadInfoD 
  RIGHT JOIN ivRecording ON ivRLHeadInfoD.RecordingID = ivRecording.Id) 
  LEFT JOIN qry_01ACvalues AS qry_01ACvalues_1 ON (ivRLHeadInfoD.MoistureCode = qry_01ACvalues_1.Code) 
  AND (ivRLHeadInfoD.MoistureResource = qry_01ACvalues_1.ResourceGIVID)) 
  LEFT JOIN qry_01ACvalues ON (ivRLHeadInfoD.GenHabCatCode = qry_01ACvalues.Code) 
  AND (ivRLHeadInfoD.GenHabCatResource = qry_01ACvalues.ResourceGIVID)
  ORDER BY ivRecording.RecordingGivid;"
  
  }


if (!multiple) {
  sql_statement <- glue_sql(common_part,
                            "AND ivS.Name LIKE {survey_name}",
                            survey_name = survey_name,
                            .con = connection)
  
} else {
  sql_statement <- glue_sql(common_part,
                            "AND ivS.Name IN ({survey_name*})",
                            survey_name = survey_name,
                            .con = connection)
}

query_result <- tbl(connection, sql(sql_statement))

if (!isTRUE(collect)) {
  return(query_result)
} else {
  query_result <- collect(query_result)
  return(query_result)
}


## Query03 Origineel uit mSQLsms

testje <- glue_sql(con , "SELECT 
                   ivRecording.RecordingGivid
                   , ivRecording.UserReference
                   , ivRecording.Observer
                   , ivRLQualifier.QualifierType
                   , ivRLQualifier.QualifierCode
                   , qry_01ACvalues.oms ## dit komt uit query01
                   , ivRLQualifier_1.QualifierCode
                   , qry_01ACvalues_1.oms  ## dit komt uit query01
                   , ivRLQualifier_2.QualifierCode
                   , qry_01ACvalues_2.oms  ## dit komt uit query01
                   , ivRLQualifier.Elucidation
                   , ivRLQualifier.NotSure
                   , ivRLQualifier.ParentID
                   FROM (((((ivRecording 
                   LEFT JOIN ivRLQualifier ON ivRecording.Id = ivRLQualifier.RecordingID) 
                   LEFT JOIN ivRLQualifier AS ivRLQualifier_1 ON 
                   ivRLQualifier.ID = ivRLQualifier_1.ParentID) 
                   LEFT JOIN ivRLQualifier AS ivRLQualifier_2 ON 
                   ivRLQualifier_1.ID = ivRLQualifier_2.ParentID) 
                   LEFT JOIN qry_01ACvalues ON (ivRLQualifier.QualifierCode = qry_01ACvalues.Code) 
                   AND (ivRLQualifier.QualifierResource = qry_01ACvalues.ResourceGIVID)) 
                   LEFT JOIN qry_01ACvalues AS qry_01ACvalues_1 ON 
                   (ivRLQualifier_1.QualifierCode = qry_01ACvalues_1.Code) 
                   AND (ivRLQualifier_1.QualifierResource = qry_01ACvalues_1.ResourceGIVID)) 
                   LEFT JOIN qry_01ACvalues AS qry_01ACvalues_2 ON 
                   (ivRLQualifier_2.QualifierCode = qry_01ACvalues_2.Code) 
                   AND (ivRLQualifier_2.QualifierResource = qry_01ACvalues_2.ResourceGIVID)
                   WHERE (((ivRLQualifier.ParentID) Is Null))
                   ORDER BY ivRecording.UserReference, ivRLQualifier.QualifierType, ivRLQualifier.QualifierCode;"
  ,.con = con)
  
############## deel uit read_iv_qualifiers_info, daarna query van jo genomen

# QUALIFIERS ophalen en linken met relevés

## inlezen nodige packages
library(tidyverse)
library(DBI)
library(glue)
library(knitr)
library(odbc)
library(assertthat)
# library(dplyr)
library(inborutils)

## connectie met de 2 databanken
con <- connect_inbo_dbase("D0010_00_Cydonia")
con_futon <- connect_inbo_dbase("D0013_00_Futon")

## opbouw functie
#3 aparte queries

## QUERY00 - UNION

# inlezen van de verschillende value-tabellen
tbl_ftQV      <- tbl(con_futon, from = "ftQualifierValues")
tbl_ftDQV     <- tbl(con_futon, from = "ftDQualifierValues")
tbl_ftAbioV   <- tbl(con_futon, from = "ftAbiotiekValues")
tbl_ftBWKV    <- tbl(con_futon, from = "ftBWKValues")
tbl_ftCoverV  <- tbl(con_futon, from = "ftCoverValues")
tbl_ftFenoV   <- tbl(con_futon, from = "ftFenoValues")
tbl_ftGebiedV <- tbl(con_futon, from = "ftgebiedValues")
tbl_ftGHCV    <- tbl(con_futon, from = "ftGHCValues")
tbl_ftLayerV  <- tbl(con_futon, from = "ftLayerValues")
tbl_ftLFV     <- tbl(con_futon, from = "ftLFValues")
tbl_ftMngmtV  <- tbl(con_futon, from = "ftMngmtValues")
tbl_ftPatchV  <- tbl(con_futon, from = "ftPatchValues")
tbl_ftN2kV    <- tbl(con_futon, from = "ftN2kValues")
tbl_ftSociaV  <- tbl(con_futon, from = "ftSociaValues")
tbl_ftSoilV   <- tbl(con_futon, from = "ftSoilValues")
tbl_ftVitaV   <- tbl(con_futon, from = "ftVitaValues")

# deze union en de drie velden ListGIVID, Code and Description behouden 
ftValues_union <-
  union(tbl_ftAbioV
        , tbl_ftBWKV
        , tbl_ftCoverV %>% rename(Description = PctValue)
        , tbl_ftDQV
        , tbl_ftFenoV
        , tbl_ftGebiedV
        , tbl_ftGHCV
        , tbl_ftLayerV
        , tbl_ftLFV
        , tbl_ftMngmtV
        , tbl_ftN2kV
        , tbl_ftPatchV
        , tbl_ftQV
        , tbl_ftSociaV
        , tbl_ftSoilV
        , tbl_ftVitaV
  ) %>%
  select(Code, Description, ListGIVID) %>% 
  collect()

# #alles in 1 keer werkt niet, dus tabel per tabel: FOUT werkt wel in 1 keer! 
# ftValues_union_001 <- 
#   union(tbl_ftQV , tbl_ftDQV) %>% 
#   select(Code, Description, ListGIVID)
# 
# ftValues_union_002 <- 
#   union(ftValues_union_001, tbl_ftAbioV) %>% 
#   select(Code, Description, ListGIVID)
# 
# ftValues_union_003 <- 
#   union(ftValues_union_002, tbl_ftBWKV) %>% 
#   select(Code, Description, ListGIVID)
# 
# # cover heeft geen Description, hier de percentage van cover-codes gebruiken
# ftValues_union_004 <- tbl_ftCoverV %>% 
#   select(Code , PctValue, ListGIVID) %>%
#   rename(Description = PctValue) %>% 
#   union(ftValues_union_003, tbl_ftCoverV) %>% 
#   select(Code, Description, ListGIVID)
# 
# ftValues_union_005 <- 
#   union(ftValues_union_004, tbl_ftFenoV) %>% 
#   select(Code, Description, ListGIVID)
# 
# ftValues_union_006 <- 
#   union(ftValues_union_005, tbl_ftGebiedV) %>% 
#   select(Code, Description, ListGIVID)
# 
# ftValues_union_007 <-
#   union(ftValues_union_006, tbl_ftGHCV) %>% 
#   select(Code, Description, ListGIVID)
# 
# ftValues_union_008 <- 
#   union(ftValues_union_007, tbl_ftLayerV) %>% 
#   select(Code, Description, ListGIVID)
# 
# ftValues_union_009 <-
#   union(ftValues_union_008, tbl_ftLFV) %>% 
#   select(Code, Description, ListGIVID)
# 
# ftValues_union_010 <-
#   union(ftValues_union_009, tbl_ftMngmtV) %>% 
#   select(Code, Description, ListGIVID)
# 
# ftValues_union_011 <-
#   union(ftValues_union_010, tbl_ftPatchV) %>% 
#   select(Code, Description, ListGIVID)
# 
# ftValues_union_012 <-
#   union(ftValues_union_011, tbl_ftN2kV) %>% 
#   select(Code, Description, ListGIVID)
# 
# ftValues_union_013 <- 
#   union(ftValues_union_012, tbl_ftSociaV) %>% 
#   select(Code, Description, ListGIVID) 
# 
# # hier gaat het mis, maar hoe kan dat? 
# # volledig zelfde opgebouwd als hierboven
# # structuur tbl_ftSoilV is zelfde
#  ftValues_union_014 <-
#   union(ftValues_union_013, tbl_ftSoilV) %>% 
#   select(Code, Description, ListGIVID) 
# 
# ftValues_union_015 <-
#   union(ftValues_union_014, tbl_ftVitaV) %>% 
#   select(Code, Description, ListGIVID) 
# 
# ## alles samen bekijken, als 014 en 015 werkt
# ftValues_union <- ftValues_union_015 %>% collect()


## QUERY01 AC-Values - dit werkt

qry_01ACvalues <- dbGetQuery(con, 
                             "SELECT 
                             ivRLResources.ResourceGIVID
                             , ivRLResources.ActionGroup
                             , ivRLResources.ListName
                             , D0013_00_Futon.dbo.ftActionGroupList.ListGIVID
                             FROM ivRLResources 
                             LEFT JOIN D0013_00_Futon.dbo.ftActionGroupList ON 
                             ivRLResources.ListName = D0013_00_Futon.dbo.ftActionGroupList.ListName 
                             collate Latin1_General_CI_AI
                             AND ivRLResources.ActionGroup = D0013_00_Futon.dbo.ftActionGroupList.ActionGroup 
                             collate Latin1_General_CI_AI 
                             ")
qry_01ACvalues %>% View()

# Linken tabel Ac-Values met de alle Values uit de Value-tables
Resources_Union <- qry_01ACvalues %>% 
  left_join(ftValues_union, by = c("ListGIVID" = "ListGIVID"), copy = TRUE) %>% 
  collect()
# View()
str(Resources_Union)
# Result:
# 'data.frame':	4372 obs. of  6 variables:
#   $ ResourceGIVID: chr  "RS2012052416033749" "RS2012052416033749" "RS2012052416033749" "RS2012052416033749" ...
# $ ActionGroup  : chr  "abiotiek" "abiotiek" "abiotiek" "abiotiek" ...
# $ ListName     : chr  "BioHab" "BioHab" "BioHab" "BioHab" ...
# $ ListGIVID    : chr  "FT2010120314510550" "FT2010120314510550" "FT2010120314510550" "FT2010120314510550" ...
# $ Code         : chr  "0" "-1" "1.1" "1.2" ...
# $ Description  : chr  "no record made" "not included in survey" "aquatic - eutrophic" "aquatic - acid" ...
# > 

# lost dit probleem op ? nee
tbl_Resources_Union <- as.data.frame(Resources_Union)
str(tbl_Resources_Union)
# 'data.frame':	4372 obs. of  6 variables:
#   $ ResourceGIVID: chr  "RS2012052416033749" "RS2012052416033749" "RS2012052416033749" "RS2012052416033749" ...
# $ ActionGroup  : chr  "abiotiek" "abiotiek" "abiotiek" "abiotiek" ...
# $ ListName     : chr  "BioHab" "BioHab" "BioHab" "BioHab" ...
# $ ListGIVID    : chr  "FT2010120314510550" "FT2010120314510550" "FT2010120314510550" "FT2010120314510550" ...
# $ Code         : chr  "0" "-1" "1.1" "1.2" ...
# $ Description  : chr  "no record made" "not included in survey" "aquatic - eutrophic" "aquatic - acid" ...

## QUERY02 MSQualifiers per opname
# Hier nog probleem bij het oproepen van Recources_Union
# ""Recources_Union" is not a recognized table hints option. If it is intended as a parameter 
# to a table-valued function or to the CHANGETABLE function, ensure that your database compatibility mode is set to 

Releve_Qualifiers <- dbGetQuery(con,
                                "SELECT 
                                ivRecording.RecordingGivid
                                , ivRecording.UserReference
                                , ivRecording.Observer
                                , ivRLQualifier.QualifierType
                                , ivRLQualifier.QualifierCode
                                , ivRLQualifier_1.QualifierCode as QualifierCode_1
                                , ivRLQualifier_2.QualifierCode as QualifierCode_2
                                , ivRLQualifier.Elucidation
                                , ivRLQualifier.NotSure
                                , ivRLQualifier.ParentID
                                , ivRLQualifier.QualifierResource
                                , ivRLQualifier_1.QualifierResource as QualifierResource_1
                                , ivRLQualifier_2.QualifierResource as QualifierResource_2
                                , Resources_Union.Description
                                FROM ivRecording
                                LEFT JOIN ivRLQualifier ON ivRecording.Id = ivRLQualifier.RecordingID 
                                LEFT JOIN ivRLQualifier AS ivRLQualifier_1 ON ivRLQualifier.ID = ivRLQualifier_1.ParentID
                                LEFT JOIN ivRLQualifier AS ivRLQualifier_2 ON ivRLQualifier_1.ID = ivRLQualifier_2.ParentID
                                LEFT_JOIN Resources_Union ON ivRLQualifier.Code = Resources_Union.Code
                                AND ivRLQualifier.QualifierResource = Resources_Union.ResourceGIVID;")

# , Recources_Union_1.Description
# , Recources_Union_2.Description
# 
#   WHERE (((ivRLQualifier.ParentID) Is Null))
#   ORDER BY ivRecording.UserReference, ivRLQualifier.QualifierType, ivRLQualifier.QualifierCode;")

## dit werkt wel 
Releve_Qualifiers_2 <- Releve_Qualifiers %>% 
  left_join(Resources_Union, by = c("QualifierCode" = "Code")) %>% 
  left_join(Resources_Union, by = c("QualifierResource" = "ResourceGIVID"))

# LEFT JOIN Resources_Union ON ivRLQualifier.QualifierCode = Resources_Union.Code
#   AND ivRLQualifier.QualifierResource = Resources_Union.ResourceGIVID")
# 
# 
#   LEFT JOIN Resources_Union AS Resources_Union_1 ON 
#                    (ivRLQualifier_1.QualifierCode = Resources_Union_1.Code)
#       AND (ivRLQualifier_1.QualifierResource = Resources_Union_1.ResourceGIVID) 
#   LEFT JOIN Resources_Union AS Resources_Union_2 ON 
#                    (ivRLQualifier_2.QualifierCode = Resources_Union_2.Code)
#       AND (ivRLQualifier_2.QualifierResource = Resources_Union.ResourceGIVID)

## 2de poging
Releve_Qualifiers <- dbGetQuery(con,
                                "SELECT 
                                ivRLQualifier.QualifierType
                                , ivRLQualifier.QualifierCode
                                , ivRLQualifier.Elucidation
                                , ivRLQualifier.NotSure
                                , ivRLQualifier.ParentID
                                , ivRLQualifier.QualifierResource
                                , tbl_Resources_Union.Description
                                FROM ivRLQualifier
                                LEFT_JOIN (tbl_Resources_Union ON ivRLQualifier.QualifierCode = tbl_Resources_Union.Code
                                AND ivRLQualifier.QualifierResource = tbl_Resources_Union.ResourceGIVID) ;")

# , Recources_Union_1.Description
# , Recources_Union_2.Description
# 
#   WHERE (((ivRLQualifier.ParentID) Is Null))
#   ORDER BY ivRecording.UserReference, ivRLQualifier.QualifierType, ivRLQualifier.QualifierCode;")

## dit werkt wel 
Releve_Qualifiers_2 <- Releve_Qualifiers %>% 
  left_join(Resources_Union, by = c("QualifierCode" = "Code")) %>% 
  left_join(Resources_Union, by = c("QualifierResource" = "ResourceGIVID"))

# 
# 
# LEFT JOIN Resources_Union ON ivRLQualifier.QualifierCode = Resources_Union.Code
# AND ivRLQualifier.QualifierResource = Resources_Union.ResourceGIVID")
# 
# 
#   LEFT JOIN Resources_Union AS Resources_Union_1 ON 
#                    (ivRLQualifier_1.QualifierCode = Resources_Union_1.Code)
#       AND (ivRLQualifier_1.QualifierResource = Resources_Union_1.ResourceGIVID) 
#   LEFT JOIN Resources_Union AS Resources_Union_2 ON 
#                    (ivRLQualifier_2.QualifierCode = Resources_Union_2.Code)
#       AND (ivRLQualifier_2.QualifierResource = Resources_Union.ResourceGIVID)




Releve_Qualifiers %>%  view()

##### origineel uit accesfronted view
origineel <- "SELECT 
ivRecording.RecordingGivid
, ivRecording.UserReference
, ivRecording.Observer
, ivRLQualifier.QualifierType
, ivRLQualifier.QualifierCode
, qry_01ACvalues.oms
, ivRLQualifier_1.QualifierCode
, qry_01ACvalues_1.oms
, ivRLQualifier_2.QualifierCode
, qry_01ACvalues_2.oms
, ivRLQualifier.Elucidation
, ivRLQualifier.NotSure
, ivRLQualifier.ParentID
FROM (((((ivRecording 
LEFT JOIN ivRLQualifier ON ivRecording.Id = ivRLQualifier.RecordingID)
LEFT JOIN ivRLQualifier AS ivRLQualifier_1 ON ivRLQualifier.ID = ivRLQualifier_1.ParentID)
LEFT JOIN ivRLQualifier AS ivRLQualifier_2 ON ivRLQualifier_1.ID = ivRLQualifier_2.ParentID) 
LEFT JOIN qry_01ACvalues ON (ivRLQualifier.QualifierCode = qry_01ACvalues.Code)
AND (ivRLQualifier.QualifierResource = qry_01ACvalues.ResourceGIVID)) 
LEFT JOIN qry_01ACvalues AS qry_01ACvalues_1 ON (ivRLQualifier_1.QualifierCode = qry_01ACvalues_1.Code) 
AND (ivRLQualifier_1.QualifierResource = qry_01ACvalues_1.ResourceGIVID)) 
LEFT JOIN qry_01ACvalues AS qry_01ACvalues_2 ON (ivRLQualifier_2.QualifierCode = qry_01ACvalues_2.Code) 
AND (ivRLQualifier_2.QualifierResource = qry_01ACvalues_2.ResourceGIVID)
WHERE (((ivRLQualifier.ParentID) Is Null))
ORDER BY ivRecording.UserReference, ivRLQualifier.QualifierType, ivRLQualifier.QualifierCode;"


## functie opbouwen - nog uitwerken, eerst hier boven in orde krijgen.

inboveg_qualifiers <- function(connection,
                               survey_name,
                               collect = FALSE,
                               multiple = FALSE) {
  
  assert_that(inherits(connection, what = "Microsoft SQL Server"),
              msg = "Not a connection object to database.")
  
  if (missing(survey_name) & !multiple) {
    survey_name <- "%"
  }
  
  if (missing(survey_name) & multiple) {
    stop("Please provide one or more survey names to survey_name when multiple
         = TRUE")
  }
  
  if (!missing(survey_name)) {
    if (!multiple) {
      assert_that(is.character(survey_name))
    } else {
      assert_that(is.vector(survey_name, mode = "character"))
    }
  }
  
  common_part <- "SELECT 
  ivRecording.RecordingGivid
  , ivRecording.UserReference
  , ivRLHeadInfoD.MoistureCode
  , qry_01ACvalues_1.oms
  , ivRLHeadInfoD.GenHabCatCode
  , qry_01ACvalues.oms
  FROM (
  (ivRLHeadInfoD 
  RIGHT JOIN ivRecording ON ivRLHeadInfoD.RecordingID = ivRecording.Id) 
  LEFT JOIN qry_01ACvalues AS qry_01ACvalues_1 ON (ivRLHeadInfoD.MoistureCode = qry_01ACvalues_1.Code) 
  AND (ivRLHeadInfoD.MoistureResource = qry_01ACvalues_1.ResourceGIVID)) 
  LEFT JOIN qry_01ACvalues ON (ivRLHeadInfoD.GenHabCatCode = qry_01ACvalues.Code) 
  AND (ivRLHeadInfoD.GenHabCatResource = qry_01ACvalues.ResourceGIVID)
  ORDER BY ivRecording.RecordingGivid;"
  
  }


if (!multiple) {
  sql_statement <- glue_sql(common_part,
                            "AND ivS.Name LIKE {survey_name}",
                            survey_name = survey_name,
                            .con = connection)
  
} else {
  sql_statement <- glue_sql(common_part,
                            "AND ivS.Name IN ({survey_name*})",
                            survey_name = survey_name,
                            .con = connection)
}

query_result <- tbl(connection, sql(sql_statement))

if (!isTRUE(collect)) {
  return(query_result)
} else {
  query_result <- collect(query_result)
  return(query_result)
}


## Query03 Origineel uit access front view

testje <- glue_sql(con , "SELECT 
  ivRecording.RecordingGivid
, ivRecording.UserReference
, ivRecording.Observer
, ivRLQualifier.QualifierType
, ivRLQualifier.QualifierCode
, qry_01ACvalues.oms ## dit komt uit query01
, ivRLQualifier_1.QualifierCode
, qry_01ACvalues_1.oms  ## dit komt uit query01
, ivRLQualifier_2.QualifierCode
, qry_01ACvalues_2.oms  ## dit komt uit query01
, ivRLQualifier.Elucidation
, ivRLQualifier.NotSure
, ivRLQualifier.ParentID
FROM (((((ivRecording 
LEFT JOIN ivRLQualifier ON ivRecording.Id = ivRLQualifier.RecordingID) 
LEFT JOIN ivRLQualifier AS ivRLQualifier_1 ON 
          ivRLQualifier.ID = ivRLQualifier_1.ParentID) 
LEFT JOIN ivRLQualifier AS ivRLQualifier_2 ON 
          ivRLQualifier_1.ID = ivRLQualifier_2.ParentID) 
LEFT JOIN qry_01ACvalues ON (ivRLQualifier.QualifierCode = qry_01ACvalues.Code) 
          AND (ivRLQualifier.QualifierResource = qry_01ACvalues.ResourceGIVID)) 
LEFT JOIN qry_01ACvalues AS qry_01ACvalues_1 ON 
          (ivRLQualifier_1.QualifierCode = qry_01ACvalues_1.Code) 
          AND (ivRLQualifier_1.QualifierResource = qry_01ACvalues_1.ResourceGIVID)) 
LEFT JOIN qry_01ACvalues AS qry_01ACvalues_2 ON 
          (ivRLQualifier_2.QualifierCode = qry_01ACvalues_2.Code) 
          AND (ivRLQualifier_2.QualifierResource = qry_01ACvalues_2.ResourceGIVID)
WHERE (((ivRLQualifier.ParentID) Is Null))
ORDER BY ivRecording.UserReference, ivRLQualifier.QualifierType, ivRLQualifier.QualifierCode;"
                   ,.con = con)






  
  
  
