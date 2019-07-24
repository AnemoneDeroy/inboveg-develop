# QUALIFIERS ophalen en linken met relevés

## inlezen nodige packages
library(tidyverse)
library(DBI)
library(glue)
library(knitr)
library(odbc)
library(assertthat)
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
#alles in 1 keer werkt niet, dus tabel per tabel
ftValues_union_001 <- 
  union(tbl_ftQV , tbl_ftDQV) %>% 
  select(Code, Description, ListGIVID)

ftValues_union_002 <- 
  union(ftValues_union_001, tbl_ftAbioV) %>% 
  select(Code, Description, ListGIVID)

ftValues_union_003 <- 
  union(ftValues_union_002, tbl_ftBWKV) %>% 
  select(Code, Description, ListGIVID)

# cover heeft geen Description, hier de percentage van cover-codes gebruiken
ftValues_union_004 <- tbl_ftCoverV %>% 
  select(Code , PctValue, ListGIVID) %>%
  rename(Description = PctValue) %>% 
  union(ftValues_union_003, tbl_ftCoverV) %>% 
  select(Code, Description, ListGIVID)

ftValues_union_005 <- 
  union(ftValues_union_004, tbl_ftFenoV) %>% 
  select(Code, Description, ListGIVID)

ftValues_union_006 <- 
  union(ftValues_union_005, tbl_ftGebiedV) %>% 
  select(Code, Description, ListGIVID)

ftValues_union_007 <-
  union(ftValues_union_006, tbl_ftGHCV) %>% 
  select(Code, Description, ListGIVID)

ftValues_union_008 <- 
  union(ftValues_union_007, tbl_ftLayerV) %>% 
  select(Code, Description, ListGIVID)

ftValues_union_009 <-
  union(ftValues_union_008, tbl_ftLFV) %>% 
  select(Code, Description, ListGIVID)

ftValues_union_010 <-
  union(ftValues_union_009, tbl_ftMngmtV) %>% 
  select(Code, Description, ListGIVID)

ftValues_union_011 <-
  union(ftValues_union_010, tbl_ftPatchV) %>% 
  select(Code, Description, ListGIVID)

ftValues_union_012 <-
  union(ftValues_union_011, tbl_ftN2kV) %>% 
  select(Code, Description, ListGIVID)

ftValues_union_013 <- 
  union(ftValues_union_012, tbl_ftSociaV) %>% 
  select(Code, Description, ListGIVID) 

# hier gaat het mis, maar hoe kan dat? 
# volledig zelfde opgebouwd als hierboven
# structuur tbl_ftSoilV is zelfde
 ftValues_union_014 <-
  union(ftValues_union_013, tbl_ftSoilV) %>% 
  select(Code, Description, ListGIVID) %>% 
   view()

ftValues_union_015 <-
  union(ftValues_union_014, tbl_ftVitaV) %>% 
  select(Code, Description, ListGIVID) 

## alles samen bekijken, als 014 en 015 werkt
ftValues_union <- ftValues_union_015 %>% collect()


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

# testen via ftValues_union_001, dus enkel Qualifiers en DQualifiers, werkt,
# nu dus die ftValues_union_014 en 015 in orde krijgen ...
Resources_Union <- qry_01ACvalues %>% 
  left_join(ftValues_union_001, by = c("ListGIVID" = "ListGIVID"), copy = TRUE) %>% 
  collect()
 # View()


## QUERY02 MSQualifiers per opname
# als QUERY00 en 01 werken ... werkt dus nog niet
# dit test met "ftValues_union_001", dus enkel Qualifiers en DrillDownQualifiers

Releve_Qualifiers <- dbGetQuery(con,
  "SELECT 
       ivRecording.RecordingGivid
     , ivRecording.UserReference
     , ivRecording.Observer
     , ivRLQualifier.QualifierType
     , ivRLQualifier.QualifierCode
     , Resources_Union.Description    
     , ivRLQualifier_1.QualifierCode
     , Resources_Union_1.Description 
     , ivRLQualifier_2.QualifierCode
     , Resources_Union_2.Description 
     , ivRLQualifier.Elucidation
     , ivRLQualifier.NotSure
     , ivRLQualifier.ParentID
  FROM ivRecording
  LEFT JOIN ivRLQualifier ON ivRecording.Id = ivRLQualifier.RecordingID 
  LEFT JOIN ivRLQualifier AS ivRLQualifier_1 ON 
                   ivRLQualifier.ID = ivRLQualifier_1.ParentID
  LEFT JOIN ivRLQualifier AS ivRLQualifier_2 ON 
                   ivRLQualifier_1.ID = ivRLQualifier_2.ParentID 
  LEFT JOIN Resources_Union ON (ivRLQualifier.QualifierCode = Resources_Union.Code) 
      AND (ivRLQualifier.QualifierResource = Resources_Union.ResourceGIVID) 
  LEFT JOIN Resources_Union AS Resources_Union_1 ON 
                   (ivRLQualifier_1.QualifierCode = Resources_Union_1.Code)
      AND (ivRLQualifier_1.QualifierResource = Resources_Union_1.ResourceGIVID) 
  LEFT JOIN Resources_Union AS Resources_Union_2 ON 
                   (ivRLQualifier_2.QualifierCode = Resources_Union_2.Code)
      AND (ivRLQualifier_2.QualifierResource = Resources_Union.ResourceGIVID)
  WHERE (((ivRLQualifier.ParentID) Is Null))
  ORDER BY ivRecording.UserReference, ivRLQualifier.QualifierType, ivRLQualifier.QualifierCode;"
                   ,.con = con)

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
  
  
  
  
  
  