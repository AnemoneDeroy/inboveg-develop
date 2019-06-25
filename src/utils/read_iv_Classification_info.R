#' @title Query Classification information from INBOVEG
#'
#' @description This function queries the INBOVEG database for information on the field classification (N2000 or BWK-code) of the relevé for one or more survey(s) by the name of the survey. See the examples for how to get information for all surveys.
#'
#' @param SurveyName A character vector giving the names of the surveys for which
#' you want to extract Classification information.
#' @param Classif A character vector giving the Classification code of the vegetation type for which
#' you want to extract information.
#' @param con dbconnection with the database 'Cydonia' on the inbo-sql07-prd server
#'
#' @return A data.frame with variables Id, SurveyName, Classification-code, BWK or N2000-list, LocalClassification, Description of the Habitattype, Cover-code, Cover in percentage.
#'
#' @importFrom glue glue_sql
#' @importFrom DBI dbGetQuery
#' @importFrom assertthat assert_that
#'
#' @examples
#' con <- DBI::dbConnect(odbc::odbc(), .connection_string = "Driver=SQL Server;Server=inbo-sql07-prd.inbo.be,1433;Database=D0010_00_Cydonia;Trusted_Connection=Yes;")
#' SurveyName <- "MILKLIM_Heischraal2012"
#' Classif <- "4010" 
#' Classif_info <- read_iv_Classification_info(SurveyName, Classif, con)
#' Allecodes <- read_iv_survey_info(SurveyName = "%", Classif = "%", .con = con)
#' dbDisconnect(con)
#' rm(con)

read_iv_classification_info <- function(SurveyName, Classif, .con) {
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

