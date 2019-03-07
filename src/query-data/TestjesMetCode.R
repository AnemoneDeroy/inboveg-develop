library(tidyverse)
library(DBI)
library(glue)
library(knitr)
library(odbc)

con <- dbConnect(odbc::odbc(), .connection_string = "Driver=SQL Server;Server=inbo-sql07-prd.inbo.be,1433;Database=D0010_00_Cydonia;Trusted_Connection=Yes;")

### Testen Survey information ###

survey_info <- function(survey, .con) {
  dbGetQuery(con, glue_sql(
    "SELECT
    ivS.Id
    , ivS.Name
    , ivS.Description
    , ivS.Owner
    , ivS.creator
    FROM [dbo].[ivSurvey] ivS
    WHERE ivS.Name LIKE {survey}", 
    ivS.Name = survey,
    .con = con ))
}

Test <- survey_info("OudeLanden_1979", con)
Test

# Nu via definieren van de parameters
survey <- "OudeLanden_1979"
Surveyinfo <- survey_info(survey, con)
Surveyinfo

## verder uitbreiden van survey _info

 survey <- "NICHE Vlaanderen"
 owner <- "INBO" 

 # AND werkt wel, OR geeft uiteraard alles van het ene of het andere.... 
 # dus toch loops maken? 
 
 # https://www.datacamp.com/community/tutorials/tutorial-on-loops-in-r
 # https://www.rdocumentation.org/packages/base/versions/3.5.2/topics/Control
 
survey_info <- function(survey, owner, .con) {
  dbGetQuery(con, glue_sql(
    "SELECT
    ivS.Id
    , ivS.Name
    , ivS.Description
    , ivS.Owner
    , ivS.creator
    FROM [dbo].[ivSurvey] ivS
    WHERE ( HIER LOOP MAKEN )

ivS.Name LIKE {survey}
    AND ivs.Owner LIKE {owner}", 
    ivS.Name = survey,
    ivS.owner = owner,
    .con = con ))
}

Test3 <- survey_info(survey, owner, con)
Test3

## testen headerinfo

header_info <- function(Name, RecType, .con) {
  dbGetQuery(con, glue_sql(
    "SELECT 
      ivR.[RecordingGivid]
      , ivS.Name
      , ivR.UserReference
      , ivR.LocationCode
      , ivR.Latitude
      , ivR.Longitude
      , ivR.Area
      , ivR.Length
      , ivR.Width
      , ivR.SurveyId
      , ivR.RecTypeID
      , coalesce(area, convert( nvarchar(20),ivR.Length * ivR.Width)) as B
      FROM [dbo].[ivRecording] ivR
      INNER JOIN [dbo].[ivSurvey] ivS on ivS.Id = ivR.SurveyId
      INNER JOIN [dbo].[ivRecTypeD] ivRec on ivRec.ID = ivR.RecTypeID 
      where ivR.NeedsWork = 0
      AND ivS.Name LIKE {Name}
      AND ivREc.Name LIKE {RecType}", 
    ivS.Name = Name,
    ivRec.Name = RecType,
    .con = con))
}

Headerinfo <- header_info("OudeLanden_1979", "Classic", con)
Headerinfo

## testen classification

SurveyName <- "OudeLanden_1979"
BWK <- "bwkcode"
N2000 <- "N2000code"

classification_info <- function(SurveyName, BWK, N2000, .con) {
  dbGetQuery(con, glue_sql(
    "SELECT 
    ivR.RecordingGivid
    , ivS.Name as survey
    , ivRLClas.Classif
    --, ivRLClas.ClassifResource
    , ivRLRes_Class.ActionGroup
    , ivRLRes_Class.ListName
    --, ftAGL_Class.ListGIVID
    --, ftBWK.ListGIVID
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
    --MAAR hoe los ik dit op als er twee type lijsten aanhangen? gevolg van vroeger opdeling in Local en AnnexI classification?
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
    AND ivS.Name LIKE {SurveyName}
    OR ivRLClas.Classif LIKE {BWK}
    OR ivRLClas.Classif LIKE {N2000}",
           ivS.Name = SurveyName,
           ivRLClas.Classif = BWK, 
           ivRLClas.Classif = N2000, 
           .con = con))
}

Classifiction <- classification_info("OudeLanden_1979", "BWK", "N2000", con)


## vegetatieopnames testen
# geeft nog probleem, misschien door in sql SMS te werken met die (syno) zodat er geen connectie nodig is voor Futon databank.


Vegetation_info <- function(SurveyName, .con) {
  dbGetQuery(con, glue_sql(
    "SELECT 
    ivR.[RecordingGivid]
    , ivRL_Layer.LayerCode
    , ivRL_Layer.CoverCode
    , ivRL_Iden.TaxonFullText as OrignalName
    , Synoniem.ScientificName
    , ivRL_Iden.PhenologyCode
    , ivRL_Taxon.CoverageCode
    , ftCover.PctValue
    , ftAGL.Description as RecordingScale
    FROM [dbo].[ivRecording] ivR 
    INNER JOIN [dbo].[ivRLLayer] ivRL_Layer on ivRL_Layer.RecordingID = ivR.Id
    INNER JOIN [dbo].[ivRLTaxonOccurrence] ivRL_Taxon on ivRL_Taxon.LayerID = ivRL_Layer.ID
    INNER JOIN [dbo].[ivRLIdentification] ivRL_Iden on ivRL_Iden.OccurrenceID = ivRL_Taxon.ID
    LEFT JOIN (SELECT ftTaxon.TaxonName AS TaxonFullText
    , COALESCE([GetSyn].TaxonName, ftTaxon.TaxonName) AS ScientificName
    , COALESCE([GetSyn].TaxonGIVID, ftTaxon.TaxonGIVID) AS TAXON_LIST_ITEM_KEY
    , COALESCE([GetSyn].TaxonQuickCode, ftTaxon.TaxonQuickCode) AS QuickCode
    FROM [syno].[Futon_dbo_ftTaxon] ftTaxon
    INNER JOIN [syno].[Futon_dbo_ftTaxonListItem] ftTLI ON ftTLI.TaxonGIVID = ftTaxon.TaxonGIVID 
    LEFT JOIN (SELECT ftTaxonLI.TaxonListItemGIVID
    , ftTaxon.TaxonGIVID
    , ftTaxon.TaxonName
    , ftTaxon.TaxonQuickCode
    , ftAGL.ListName
    , ftTaxonLI.PreferedListItemGIVID
    FROM [syno].[Futon_dbo_ftActionGroupList] ftAGL 
    INNER JOIN [syno].[Futon_dbo_ftTaxonListItem] ftTaxonLI ON ftTaxonLI.TaxonListGIVID = ftAGL.ListGIVID 
    LEFT JOIN [syno].[Futon_dbo_ftTaxon] ftTaxon ON ftTaxon.TaxonGIVID = ftTaxonLI.TaxonGIVID 
    WHERE 1=1
    AND ftAGL.ListName = 'INBO-2011 Sci'	
    ) GetSyn ON GetSyn.TaxonListItemGIVID = ftTLI.PreferedListItemGIVID
    WHERE ftTLI.TaxonListGIVID = 'TL2011092815101010'
    ) Synoniem on ivRL_Iden.TaxonFullText = Synoniem.TaxonFullText collate Latin1_General_CI_AI
    LEFT JOIN [dbo].[ivRLResources] ivRL_Res on ivRL_Res.ResourceGIVID = ivRL_Taxon.CoverageResource
    LEFT JOIN [syno].[Futon_dbo_ftActionGroupList] ftAGL on ftAGL.ActionGroup = ivRL_Res.ActionGroup collate Latin1_General_CI_AI
    AND ftAGL.ListName = ivRL_Res.ListName collate Latin1_General_CI_AI
    LEFT JOIN [syno].[Futon_dbo_ftCoverValues] ftCover on ftCover.ListGIVID = ftAGL.ListGIVID
    AND ivRL_Taxon.CoverageCode = ftCover.Code collate Latin1_General_CI_AI
    WHERE ivR.NeedsWork = 0
    AND ivRL_Iden.Preferred = 1
    AND ivS.Name LIKE {SurveyName}", 
               ivS.Name = SurveyName,
               .con = con ))
}

Vegetation_info("OudeLanden_1979", con)