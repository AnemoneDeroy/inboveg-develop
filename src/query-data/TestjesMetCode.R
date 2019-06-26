library(tidyverse)
library(DBI)
library(glue)
library(knitr)
library(odbc)
library(assertthat)


source("./src/utils/read_iv_survey_info.R")
## thuis putty maken en vpn opzetten
con <- dbConnect(odbc::odbc(), .connection_string = "Driver=SQL Server;Server=inbo-sql07-prd.inbo.be,1433;Database=D0010_00_Cydonia;Trusted_Connection=Yes;")

### Testen Survey information ###

Test <- read_iv_survey_info(survey = "OudeLanden_1979", .con = con)
Alles <- read_iv_survey_info(survey = "%", .con = con)

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

## voorbeeld 
survey <- "OudeLanden_1979"
SurveyInfo <- survey_info(survey, con)
SurveyInfo

## wil je ganse lijst van surveys:  
AlleSurveys <- survey_info(survey = "%", .con = con)

###############

# als je slechts deel weet van de naam van Survey
Deel_qry <- Alles %>%
  select(Name, Description) %>%
  filter(str_detect(tolower(Name), pattern = "torf"))
# dit in functie kappen

Part_of_SurveyName <- function(con, part) {
  Deel_qry <-
    past0(Alles %>%
    select(Name, Description) %>%
    filter(str_detect(tolower(Name), pattern = "part")))
  DBI::dbGetQuery(con, Deel_qry)

}

part <- 'torf'
torf <-  Part_of_SurveyName(con, part)
## FOUTMELDING 
#Error in past0(Alles %>% select(Name, Description) %>% filter(str_detect(tolower(Name),  : could not find function "past0"


## Weet je slechts een part van de naam, voorbeeld enkel 'torf':
Deel <-'torf'
DeelSurvey <- survey_info(is.character(survey = (str_detect(tolower(Name), "torf"))), con)
## werkt niet

##### PRUTSJES met dplyr
tbl_survey <- tbl(con, from = "ivSurvey")
class(tbl_survey)

tbl_survey$ops$vars 

survey_info <- function(survey, con) {
  tbl_survey %>%
    select(Id, Name, Description, Owner, Creator) %>% 
    filter(survey %LIKE% (str_c("%", survey, "%"))) %>% 
    pull()
  
}

##
Survey <- tbl(con, from = "ivSurvey")

Survey %>% 
  select("Name") %>% 
  filter(Name = "OudeLanden_1979" )


## Only a part of the survey name is known? Or all the surveys of "MILKLIM" for example want to be given

survey_info <- function(survey, con) {
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


Part <-"torf"
PartSurvey <- survey_info(survey = (str_detect(tolower(Name), "PART"))) ## dit werkt dus nog niet!!
survey_info(table = survey, survey = Part) #should work?


PartSurveys <- survey_info(survey = "%MILKLIM%", con)

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
    WHERE (
        if (survey is not null)
            , ivS.Name LIKE {survey}
        , else (
      if (owner is not null)
            ,ivs.Owner LIKE {owner}
        ,else print ('sorry no valid answer')

  )",
    ivS.Name = survey,
    ivS.owner = owner,
    .con = con ))
}

Test3 <- survey_info(survey, owner, con)
Test3


#############################
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


Name <- "OudeLanden_1979"
RecType <- "Classic"
Headerinfo <- read_iv_header_info_edb(Name, RecType, con)
dbDisconnect(con)
rm(con)


###############################
## testen classification - N2000 

SurveyName <- "MILKLIM_Heischraal2012"
N2000 <- "4010"

classification_info <- function(SurveyName, N2000, .con) {
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
        AND ivRLClas.Classif LIKE {N2000}",
           ivS.Name = SurveyName,
           ivRLClas.Classif = N2000,
           .con = con))
}

Classifiction <- classification_info("MILKLIM_Heischraal2012", "%", con)
Test <- classification_info(SurveyName, N2000, .con)

## opkuisen code, verwijderen info bwk

classification_info2 <- function(SurveyName, N2000, .con) {
  dbGetQuery(con, glue_sql(
    "SELECT
    ivR.RecordingGivid
    , ivS.Name as survey
    , ivRLClas.Classif
    , ivRLRes_Class.ActionGroup
    , ivRLRes_Class.ListName
    , ftN2k.Description  as Habitattype
    , ivRLClas.Cover
    , ftC.PctValue
    FROM ivRecording ivR
    INNER JOIN ivSurvey ivS on ivS.Id = ivR.surveyId
    LEFT JOIN [dbo].[ivRLClassification] ivRLClas on ivRLClas.RecordingID = ivR.Id
    LEFT JOIN [dbo].[ivRLResources] ivRLRes_Class on ivRLRes_Class.ResourceGIVID = ivRLClas.ClassifResource
    LEFT JOIN [syno].[Futon_dbo_ftActionGroupList] ftAGL_Class on ftAGL_Class.ActionGroup = ivRLRes_Class.ActionGroup collate Latin1_General_CI_AI
    AND ftAGL_Class.ListName = ivRLRes_Class.ListName collate Latin1_General_CI_AI
    LEFT JOIN [syno].[Futon_dbo_ftN2kValues] ftN2K on ftN2K.Code = ivRLClas.Classif collate Latin1_General_CI_AI
    AND ftN2K.ListGIVID = ftAGL_Class.ListGIVID
    LEFT JOIN [dbo].[ivRLResources] ivRLR_C on ivRLR_C.ResourceGIVID = ivRLClas.CoverResource
    LEFT JOIN [syno].[Futon_dbo_ftActionGroupList] ftAGL_C on ftAGL_C.ActionGroup = ivRLR_C.ActionGroup collate Latin1_General_CI_AI
    AND ftAGL_C.ListName = ivRLR_C.ListName collate Latin1_General_CI_AI
    LEFT JOIN [syno].[Futon_dbo_ftCoverValues] ftC on ftC.Code = ivRLClas.Cover collate Latin1_General_CI_AI
    AND ftAGL_C.ListGIVID = ftC.ListGIVID
    WHERE ivRLClas.Classif is not NULL
    AND ivS.Name LIKE {SurveyName}
    AND ivRLClas.Classif LIKE {N2000}",
    ivS.Name = SurveyName,
    ivRLClas.Classif = N2000,
    .con = con))
}
Classifiction2 <- classification_info2("MILKLIM_Heischraal2012", "%", con)

## testen enkle met bwk code
## iv_Classification_BWK

classification_info_bwk2 <- function(SurveyName, BWK, .con) {
  dbGetQuery(con, glue_sql(
    "SELECT 
    ivR.RecordingGivid
    , ivS.Name as survey
    , ivRLClas.Classif
    , ivRLRes_Class.ActionGroup
    , ivRLRes_Class.ListName
    , ftBWK.Description as LocalClassification
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
    LEFT JOIN [dbo].[ivRLResources] ivRLR_C on ivRLR_C.ResourceGIVID = ivRLClas.CoverResource
    LEFT JOIN [syno].[Futon_dbo_ftActionGroupList] ftAGL_C on ftAGL_C.ActionGroup = ivRLR_C.ActionGroup collate Latin1_General_CI_AI
    AND ftAGL_C.ListName = ivRLR_C.ListName collate Latin1_General_CI_AI
    LEFT JOIN [syno].[Futon_dbo_ftCoverValues] ftC on ftC.Code = ivRLClas.Cover collate Latin1_General_CI_AI
    AND ftAGL_C.ListGIVID = ftC.ListGIVID 
    WHERE ivRLClas.Classif is not NULL 
    AND ivS.Name LIKE {SurveyName}
    AND ivRLClas.Classif LIKE {BWK}",
    ivS.Name = SurveyName,
    ivRLClas.Classif = BWK, 
    .con = con))
}


SurveyName <- "CultuurgraslandTypologie"
BWK <- "h"
Classifiction_bwk <- classification_info_bwk(SurveyName, BWK, con)
Classifiction_bwk2 <- classification_info_bwk2("CultuurgraslandTypologie", "h", con) 


## niet opgedeeld in N2000 of BWK
read_iv_classification_info <- function(SurveyName, Classif, .con) {
  dbGetQuery(con, glue_sql(
    "SELECT
    ivR.RecordingGivid
    , ivS.Name as survey
    , ivRLClas.Classif as Classification code
    , ivRLRes_Class.ActionGroup as List
    , ivRLRes_Class.ListName
    , ftBWK.Description as LocalClassification
    , ftN2k.Description as Habitattype
    , ivRLClas.Cover
    , ftC.PctValue as percentage cover
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
    AND ivS.Name LIKE {SurveyName}
    AND ivRLClas.Classif LIKE {Classif}",
    ivS.Name = SurveyName,
    ivRLClas.Classif = Classif,
    .con = con))
}

SurveyName <- "MILKLIM_Heischraal2012"
Classif <- "4010" 
Classif_info <- read_iv_classification_info(SurveyName, Classif, con)
Classif_info2 <- read_iv_classification_info("MILKLIM_Heischraal2012", "4010", con)
Allecodes <- read_iv_classification_info(SurveyName = "%", Classif = "%", .con = con)



## uit Msql SMS
read_iv_classification_info_alles <- function(SurveyName, Classif, .con) {
  dbGetQuery(con, glue_sql(
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
    WHERE ivRLClas.Classif is not NULL ",
    ivS.Name = SurveyName,
    ivRLClas.Classif = Classif,
    .con = con))
}

SurveyName <- "MILKLIM_Heischraal2012"
Classif <- "4010" 
Classif_info <- read_iv_classification_info_alles(SurveyName, Classif, con)
Classif_info2 <- read_iv_classification_info_alles("MILKLIM_Heischraal2012", "4010", con)
Allecodes <- read_iv_classification_info_alles(SurveyName = "%", Classif = "%", .con = con)

###################
## vegetatieopnames testen

### uit MsqlSMS en dan in functie kappen
## geeft altijd lege velden, werkt wel met recordingGIVID

relevé_info_RecordingGivid <- function(RecordingGivid, .con) {
  dbGetQuery(con, glue_sql(
                "SELECT ivR.[RecordingGivid]
	                      , ivRL_Layer.LayerCode
                        , ivRL_Layer.CoverCode
                        , ivRL_Iden.TaxonFullText as OrignalName
                        , Synoniem.ScientificName
                        , ivRL_Iden.PhenologyCode
                        , ivRL_Taxon.CoverageCode
                        , ftCover.PctValue
                        , ftAGL.Description as RecordingScale
                FROM [dbo].[ivRecording] ivR 
       -- Deel met soortenlijst en synoniem
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
         -- Hier begint deel met bedekking
                LEFT JOIN [dbo].[ivRLResources] ivRL_Res on ivRL_Res.ResourceGIVID = ivRL_Taxon.CoverageResource
                LEFT JOIN [syno].[Futon_dbo_ftActionGroupList] ftAGL on ftAGL.ActionGroup = ivRL_Res.ActionGroup collate Latin1_General_CI_AI
                AND ftAGL.ListName = ivRL_Res.ListName collate Latin1_General_CI_AI
                LEFT JOIN [syno].[Futon_dbo_ftCoverValues] ftCover on ftCover.ListGIVID = ftAGL.ListGIVID
                AND ivRL_Taxon.CoverageCode = ftCover.Code collate Latin1_General_CI_AI
                WHERE ivR.NeedsWork = 0
                AND ivRL_Iden.Preferred = 1
                -- AND ivR.RecordingGivid = 'IV2014070310423184' --(dees bevat Betula pubescens Ehrh., in inboveg is prefered Betula alba L.
                AND ivR.RecordingGivid LIKE {RecordingGivid}",
                ivR.RecordingGivid = RecordingGivid,
                .con = con))
}

# Example 
Betula <- relevé_info("IV2014070310423184", con)

## nu ombouwen naar basis van SurveyName ipv recordingGIVID
relevé_info_surveyname <- function(SurveyName, .con) {
  dbGetQuery(con, glue_sql(
          "SELECT ivS.Name
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
      -- Hier begint deel met bedekking
          LEFT JOIN [dbo].[ivRLResources] ivRL_Res on ivRL_Res.ResourceGIVID = ivRL_Taxon.CoverageResource
          LEFT JOIN [syno].[Futon_dbo_ftActionGroupList] ftAGL on ftAGL.ActionGroup = ivRL_Res.ActionGroup collate Latin1_General_CI_AI
          AND ftAGL.ListName = ivRL_Res.ListName collate Latin1_General_CI_AI
          LEFT JOIN [syno].[Futon_dbo_ftCoverValues] ftCover on ftCover.ListGIVID = ftAGL.ListGIVID
          AND ivRL_Taxon.CoverageCode = ftCover.Code collate Latin1_General_CI_AI
          --WHERE ivR.NeedsWork = 0
          AND ivRL_Iden.Preferred = 1
          -- AND ivR.RecordingGivid = 'IV2014070310423184' --(dees bevat Betula pubescens Ehrh., in inboveg is prefered Betula alba L.
          AND ivS.Name LIKE {SurveyName}",
                ivS.Name = Name,
                .con = con))
}

# Example 
OudeLanden <- relevé_info_surveyname("OudeLanden_1979", con)




















## Werken met 2 verbindingen? geen oplossing en blijkbaar ook niet nodig 
# geeft nog probleem, misschien door in sql SMS te werken met die (syno) zodat er geen connectie nodig is voor Futon databank.

con_Cydonia <- dbConnect(odbc::odbc(), .connection_string = "Driver=SQL Server;Server=inbo-sql07-prd.inbo.be,1433;Database=D0010_00_Cydonia;Trusted_Connection=Yes;")
con_Futon <- dbConnect(odbc::odbc(), .connection_string = "Driver=SQL Server;Server=inbo-sql07-prd.inbo.be,1433;Database=D0013_00_Futon;Trusted_Connection=Yes;")

Vegetation_info <- function(SurveyName, con_Cydonia, con_Futon) {
  dbGetQuery(con_Cydonia, con_Futon, glue_sql(
    "SELECT
    D0010_00_Cydonia.ivR.[RecordingGivid]
    , D0010_00_Cydonia.ivRL_Layer.LayerCode
    , D0010_00_Cydonia.ivRL_Layer.CoverCode
    , D0010_00_Cydonia.ivRL_Iden.TaxonFullText as OrignalName
    , Synoniem.ScientificName
    , D0010_00_Cydonia.ivRL_Iden.PhenologyCode
    , D0010_00_Cydonia.ivRL_Taxon.CoverageCode
    , D0013_00_Futon.ftCover.PctValue
    , D0013_00_Futon.ftAGL.Description as RecordingScale
    FROM [D0010_00_Cydonia].[dbo].[ivRecording] ivR
    INNER JOIN [D0010_00_Cydonia].[dbo].[ivRLLayer] ivRL_Layer on ivRL_Layer.RecordingID = ivR.Id
    INNER JOIN [D0010_00_Cydonia].[dbo].[ivRLTaxonOccurrence] ivRL_Taxon on ivRL_Taxon.LayerID = ivRL_Layer.ID
    INNER JOIN [D0010_00_Cydonia].[dbo].[ivRLIdentification] ivRL_Iden on ivRL_Iden.OccurrenceID = ivRL_Taxon.ID
    LEFT JOIN (SELECT ftTaxon.TaxonName AS TaxonFullText
    , COALESCE([GetSyn].TaxonName, ftTaxon.TaxonName) AS ScientificName
    , COALESCE([GetSyn].TaxonGIVID, ftTaxon.TaxonGIVID) AS TAXON_LIST_ITEM_KEY
    , COALESCE([GetSyn].TaxonQuickCode, ftTaxon.TaxonQuickCode) AS QuickCode
    FROM [D0013_00_Futon].[dbo].[ftTaxon] ftTaxon
    INNER JOIN [D0013_00_Futon].[dbo].[ftTaxonListItem] ftTLI ON ftTLI.TaxonGIVID = ftTaxon.TaxonGIVID
    LEFT JOIN (SELECT ftTaxonLI.TaxonListItemGIVID
    , ftTaxon.TaxonGIVID
    , ftTaxon.TaxonName
    , ftTaxon.TaxonQuickCode
    , ftAGL.ListName
    , ftTaxonLI.PreferedListItemGIVID
    FROM [D0013_00_Futon].[dbo].[ftActionGroupList] ftAGL
    INNER JOIN [D0013_00_Futon].[dbo].[ftTaxonListItem] ftTaxonLI ON ftTaxonLI.TaxonListGIVID = ftAGL.ListGIVID
    LEFT JOIN [D0013_00_Futon].[dbo].[ftTaxon] ftTaxon ON ftTaxon.TaxonGIVID = ftTaxonLI.TaxonGIVID
    WHERE 1=1
    AND ftAGL.ListName = 'INBO-2011 Sci'
    ) GetSyn ON GetSyn.TaxonListItemGIVID = ftTLI.PreferedListItemGIVID
    WHERE ftTLI.TaxonListGIVID = 'TL2011092815101010'
    ) Synoniem on ivRL_Iden.TaxonFullText = Synoniem.TaxonFullText collate Latin1_General_CI_AI
    LEFT JOIN [D0010_00_Cydonia].[dbo].[ivRLResources] ivRL_Res on ivRL_Res.ResourceGIVID = ivRL_Taxon.CoverageResource
    LEFT JOIN [D0013_00_Futon].[dbo].[ftActionGroupList] ftAGL on ftAGL.ActionGroup = ivRL_Res.ActionGroup collate Latin1_General_CI_AI
    AND ftAGL.ListName = ivRL_Res.ListName collate Latin1_General_CI_AI
    LEFT JOIN [D0013_00_Futon].[dbo].[ftCoverValues] ftCover on ftCover.ListGIVID = ftAGL.ListGIVID
    AND ivRL_Taxon.CoverageCode = ftCover.Code collate Latin1_General_CI_AI
    WHERE ivR.NeedsWork = 0
    AND ivRL_Iden.Preferred = 1
    AND ivS.Name LIKE {SurveyName}",
               ivS.Name = SurveyName,
               .con = con_Cydonia, 
                .con2 = con_Futon))
}

OudeLanden <- Vegetation_info("OudeLanden_1979", con_Cydonia, con_Futon)


## van hans gekregen mail 25/06

iv_opnamen <- dbGetQuery(con, 
                    "SELECT 
                         ivRecording.RecordingGivid
                        , ivRecording.LocationCode
                        , ivRLLayer.LayerCode
                         , ivRLLayer.CoverCode
                         , ivRLIdentification.TaxonFullText AS OriginalName
                         , ivRLIdentification.PhenologyCode
                         , ivRLTaxonOccurrence.CoverageCode
                         , ftCoverValues.PctValue
                         , ftActionGroupList.Description
                         , ivRLIdentification.TaxonGroup
                         , ivRecording.VagueDateType
                         , ivRecording.VagueDateBegin
                         , ivRecording.VagueDateEnd
                         , ivRecTypeD.Name
                         FROM 
                         --Cydonia
                         dbo.ivRecTypeD 
                         INNER JOIN dbo.ivRecording ON ivRecording.RecTypeID = ivRecTypeD.ID
                         INNER JOIN dbo.ivSurvey ON ivSurvey.Id = ivRecording.SurveyId
                         LEFT JOIN dbo.ivRLLayer ON ivRLLayer.RecordingID = ivRecording.Id
                         LEFT JOIN dbo.ivRLTaxonOccurrence ON ivRLTaxonOccurrence.LayerID = ivRLLayer.ID 
                         LEFT JOIN dbo.ivRLIdentification ON ivRLIdentification.OccurrenceID = ivRLTaxonOccurrence.ID 
                         LEFT JOIN dbo.ivRLResources ON ivRLResources.ResourceGIVID = ivRLTaxonOccurrence.CoverageResource 
                         --Futon
                         LEFT JOIN D0013_00_Futon.dbo.ftActionGroupList ON ftActionGroupList.ListName = ivRLResources.ListName COLLATE Latin1_General_CI_AI
                         LEFT JOIN D0013_00_Futon.dbo.ftCoverValues ON ftCoverValues.ListGIVID = ftActionGroupList.ListGIVID COLLATE Latin1_General_CI_AI
                         AND ftCoverValues.Code = [ivRLTaxonOccurrence].[CoverageCode] COLLATE Latin1_General_CI_AI
                         WHERE 1=1
                         AND ivRLIdentification.Preferred = 1
                         AND ivRecTypeD.Name IN ('Classic', 'Classic-emmer', 'Classic-ketting')
                          AND ivSurvey.Name IN ('Sigma_LSVI_2012', '')
                         ORDER BY ivRLLayer.LayerCode;
                         ")


# Tabel taxonomie
iv_geef_synoniem <-
  dbGetQuery(con,
             "SELECT ftt.TaxonName AS TaxonFullText
             , COALESCE([qry_B_GetSyn].TaxonName, ftt.TaxonName) AS ScientificName
             , COALESCE([qry_B_GetSyn].TaxonGIVID, ftt.TaxonGIVID) AS TAXON_LIST_ITEM_KEY
             , COALESCE([qry_B_GetSyn].TaxonQuickCode, ftt.TaxonQuickCode) AS QuickCode
             FROM D0013_00_Futon.dbo.ftTaxon ftt
             INNER JOIN D0013_00_Futon.dbo.ftTaxonListItem tli ON tli.TaxonGIVID = ftt.TaxonGIVID 
             INNER JOIN (SELECT ftTaxonListItem.TaxonListItemGIVID
             , ftTaxon.TaxonGIVID
             , ftTaxon.TaxonName
             , ftTaxon.TaxonQuickCode
             , ftActionGroupList.ListName
             , ftTaxonListItem.PreferedListItemGIVID
             FROM D0013_00_Futon.dbo.ftActionGroupList 
             INNER JOIN D0013_00_Futon.dbo.ftTaxonListItem ON ftTaxonListItem.TaxonListGIVID = ftActionGroupList.ListGIVID 
             LEFT JOIN D0013_00_Futon.dbo.ftTaxon ON ftTaxon.TaxonGIVID = ftTaxonListItem.TaxonGIVID 
             WHERE 1=1
             AND ftActionGroupList.ListName = 'INBO-2011 Sci'	
             ) qry_B_GetSyn ON tli.PreferedListItemGIVID = qry_B_GetSyn.TaxonListItemGIVID
             WHERE tli.TaxonListGIVID = 'TL2011092815101010'
             ORDER BY ftt.TaxonName;"
  )

# Tabel met alle survey gegevens
iv_survey <- dbReadTable(con, "ivSurvey")

# query voor alle 'vegetatielagen' te bekomen, ook die zonder vegetatie 
# (strooisellaag, naakte bodem,...):

iv_veglagen <- dbGetQuery(con, "SELECT ivRecording.RecordingGivid
                          , ivRLLayer.LayerCode
                          , ftCoverValues.PctValue
                          FROM ((dbo.ivRecording 
                          LEFT JOIN (dbo.ivRLLayer 
                          INNER JOIN dbo.ivRLResources 
                          ON ivRLLayer.CoverResource = ivRLResources.ResourceGIVID) 
                          ON ivRecording.Id = ivRLLayer.RecordingID) 
                          INNER JOIN D0013_00_Futon.dbo.ftActionGroupList 
                          ON (ivRLResources.ListName COLLATE Latin1_General_CI_AI = ftActionGroupList.ListName COLLATE Latin1_General_CI_AI) AND (ivRLResources.ActionGroup COLLATE Latin1_General_CI_AI = ftActionGroupList.ActionGroup COLLATE Latin1_General_CI_AI)) 
                          INNER JOIN D0013_00_Futon.dbo.ftCoverValues 
                          ON (ivRLLayer.CoverCode COLLATE Latin1_General_CI_AI = ftCoverValues.Code COLLATE Latin1_General_CI_AI) AND (ftActionGroupList.ListGIVID = ftCoverValues.ListGIVID)
                          ;
                          ")



dbDisconnect(con)

rm(con)
