library(tidyverse)
library(DBI)
library(glue)
library(knitr)
library(odbc)
library(assertthat)
library(inborutils)

con <- connect_inbo_dbase("D0010_00_Cydonia")
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
    select(Code, Description, ListGIVID)

## RESULT:  
# Source:   lazy query [?? x 3]
# Database: Microsoft SQL Server 13.00.5216[INBO\els_debie@INBO-SQL07-PRD\LIVE/D0013_00_Futon]

## Kortere manier dan via union en alle tabellen apart in te lezen?

## QUERY01 ACValues
qry_01ACvalues <- dbGetQuery(con, glue_sql(
  "SELECT 
       ivRLResources.ResourceGIVID
     , ivRLResources.ActionGroup
     , ivRLResources.ListName
     , ftValues_union.Code
     , ftValues_union.Description
  FROM ivRLResources 
  LEFT JOIN D0013_00_Futon.dbo.ftActionGroupList ON ivRLResources.ListName = D0013_00_Futon.dbo.ftActionGroupList.ListName
  AND ivRLResources.ActionGroup = D0013_00_Futon.dbo.ftActionGroupList.ActionGroup
  LEFT JOIN ftValues_union ON D0013_00_Futon.dbo.ftActionGroupList.ListGIVID = ftValues_union.ListGIVID"
  ))

dbBind(qry_01ACvalues())

#" hoe data opvragen? zonder functie met sql en niet met dplyr





## QUERY02 Alles verbinden MSQualifiers per opname
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
  
  
  
  
  
  