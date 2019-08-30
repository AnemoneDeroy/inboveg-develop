# Opbouwen van voorbeeldqueries, op basis van de aangeboden functies

## inlezen nodige packages
library(tidyverse)
library(DBI)
library(glue)
library(knitr)
library(odbc)
library(assertthat)

library(inborutils)

## connectie met databank
connection <- connect_inbo_dbase("D0010_00_Cydonia")

## Voorbeeld Classif aan bepaald recordingGIVID 

### recording ophalen met functie:
inboveg_recordings <- function(connection,
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
  
  common_part <- "SELECT ivS.Name
  , ivR.[RecordingGivid]
  , ivRL_Layer.LayerCode
  , ivRL_Layer.CoverCode
  , ivRL_Iden.TaxonFullText as OrignalName
  , Synoniem.ScientificName
  , ivRL_Iden.PhenologyCode
  , ivRL_Taxon.CoverageCode
  , ftCover.PctValue
  , ftAGL.Description as RecordingScale
  FROM  dbo.ivSurvey ivS
  INNER JOIN [dbo].[ivRecording] ivR  ON ivR.SurveyId = ivS.Id
  -- Deel met soortenlijst en synoniem
  INNER JOIN [dbo].[ivRLLayer] ivRL_Layer on ivRL_Layer.RecordingID = ivR.Id
  INNER JOIN [dbo].[ivRLTaxonOccurrence] ivRL_Taxon on
  ivRL_Taxon.LayerID = ivRL_Layer.ID
  INNER JOIN [dbo].[ivRLIdentification] ivRL_Iden on
  ivRL_Iden.OccurrenceID = ivRL_Taxon.ID
  LEFT JOIN (SELECT ftTaxon.TaxonName AS TaxonFullText
  , COALESCE([GetSyn].TaxonName, ftTaxon.TaxonName) AS ScientificName
  , COALESCE([GetSyn].TaxonGIVID, ftTaxon.TaxonGIVID) AS TAXON_LIST_ITEM_KEY
  , COALESCE([GetSyn].TaxonQuickCode, ftTaxon.TaxonQuickCode) AS QuickCode
  FROM [syno].[Futon_dbo_ftTaxon] ftTaxon
  INNER JOIN [syno].[Futon_dbo_ftTaxonListItem] ftTLI ON
  ftTLI.TaxonGIVID = ftTaxon.TaxonGIVID
  LEFT JOIN (SELECT ftTaxonLI.TaxonListItemGIVID
  , ftTaxon.TaxonGIVID
  , ftTaxon.TaxonName
  , ftTaxon.TaxonQuickCode
  , ftAGL.ListName
  , ftTaxonLI.PreferedListItemGIVID
  FROM [syno].[Futon_dbo_ftActionGroupList] ftAGL
  INNER JOIN [syno].[Futon_dbo_ftTaxonListItem] ftTaxonLI ON
  ftTaxonLI.TaxonListGIVID = ftAGL.ListGIVID
  LEFT JOIN [syno].[Futon_dbo_ftTaxon] ftTaxon ON
  ftTaxon.TaxonGIVID = ftTaxonLI.TaxonGIVID
  WHERE 1=1
  AND ftAGL.ListName = 'INBO-2011 Sci'
  ) GetSyn
  ON GetSyn.TaxonListItemGIVID = ftTLI.PreferedListItemGIVID
  WHERE ftTLI.TaxonListGIVID = 'TL2011092815101010'
  ) Synoniem on
  ivRL_Iden.TaxonFullText = Synoniem.TaxonFullText collate Latin1_General_CI_AI
  -- Hier begint deel met bedekking
  LEFT JOIN [dbo].[ivRLResources] ivRL_Res on
  ivRL_Res.ResourceGIVID = ivRL_Taxon.CoverageResource
  LEFT JOIN [syno].[Futon_dbo_ftActionGroupList] ftAGL on
  ftAGL.ActionGroup = ivRL_Res.ActionGroup collate Latin1_General_CI_AI
  AND ftAGL.ListName = ivRL_Res.ListName collate Latin1_General_CI_AI
  LEFT JOIN [syno].[Futon_dbo_ftCoverValues] ftCover on
  ftCover.ListGIVID = ftAGL.ListGIVID
  AND ivRL_Taxon.CoverageCode = ftCover.Code collate Latin1_General_CI_AI
  WHERE 1=1
  AND ivRL_Iden.Preferred = 1"
  
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
}

#### Heischraal 
recording_heischraal2012 <- inboveg_recordings(connection, survey_name = "MILKLIM_Heischraal2012", collect = TRUE)

### Classification
inboveg_classification <- function(connection,
                                   survey_name,
                                   classif,
                                   collect = FALSE) {
  
  assert_that(inherits(connection, what = "Microsoft SQL Server"),
              msg = "Not a connection object to database.")
  
  if (missing(survey_name)) {
    survey_name <- "%"
  } else {
    assert_that(is.character(survey_name))
  }
  
  if (missing(classif)) {
    classif <- "%"
  } else {
    assert_that(is.character(classif))
  }
  
  sql_statement <- glue_sql(
    "Select ivR.RecordingGivid
    , ivS.Name
    , ivRLClas.Classif
    , ivRLRes_Class.ActionGroup
    , ivRLRes_Class.ListName
    , ftBWK.Description as LocalClassification
    , ftN2k.Description  as Habitattype
    , ivRLClas.Cover
    , ftC.PctValue
    FROM ivRecording ivR
    INNER JOIN ivSurvey ivS on ivS.Id = ivR.surveyId
    LEFT JOIN [dbo].[ivRLClassification] ivRLClas on ivRLClas.RecordingID = ivR.Id
    LEFT JOIN [dbo].[ivRLResources] ivRLRes_Class on ivRLRes_Class.ResourceGIVID = ivRLClas.ClassifResource
    LEFT JOIN [syno].[Futon_dbo_ftActionGroupList] ftAGL_Class on ftAGL_Class.ActionGroup = ivRLRes_Class.ActionGroup collate Latin1_General_CI_AI
    AND ftAGL_Class.ListName = ivRLRes_Class.ListName collate Latin1_General_CI_AI
    LEFT JOIN [syno].[Futon_dbo_ftBWKValues] ftBWK on ftBWK.Code = ivRLClas.Classif collate Latin1_General_CI_AI
    AND ftBWK.ListGIVID = ftAGL_Class.ListGIVID
    LEFT JOIN [syno].[Futon_dbo_ftN2kValues] ftN2K on ftN2K.Code = ivRLClas.Classif collate Latin1_General_CI_AI
    AND ftN2K.ListGIVID = ftAGL_Class.ListGIVID
    LEFT JOIN [dbo].[ivRLResources] ivRLR_C on ivRLR_C.ResourceGIVID = ivRLClas.CoverResource
    LEFT JOIN [syno].[Futon_dbo_ftActionGroupList] ftAGL_C on ftAGL_C.ActionGroup = ivRLR_C.ActionGroup collate Latin1_General_CI_AI
    AND ftAGL_C.ListName = ivRLR_C.ListName collate Latin1_General_CI_AI
    LEFT JOIN [syno].[Futon_dbo_ftCoverValues] ftC on ftC.Code = ivRLClas.Cover collate Latin1_General_CI_AI
    AND ftAGL_C.ListGIVID = ftC.ListGIVID
    WHERE ivRLClas.Classif is not NULL
    AND ivS.Name LIKE {survey_name}
    AND ivRLClas.Classif LIKE {classif}",
    survey_name = survey_name,
    classif = classif,
    .con = connection)

  query_result <- tbl(connection, sql(sql_statement))

  if (!isTRUE(collect)) {
    return(query_result)
  } else {
    query_result <- collect(query_result)
    return(query_result)
  }
}

#### voorbeeld
classif_info <- inboveg_classification(connection, survey_name = "MILKLIM_Heischraal2012", classif = "4010", collect = TRUE)


## Samen leggen

test <- recording_heischraal2012 %>% 
  inner_join(classif_info, by = "RecordingGivid") %>% 
  select(RecordingGivid, ScientificName, Classif, Cover) 

  
  

