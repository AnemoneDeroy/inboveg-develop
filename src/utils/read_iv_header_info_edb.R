#' @title Query Header information from INBOVEG
#'
#' @description This function queries the INBOVEG database for Header information (metadata for a vegetation-relevé) for one survey by the name of the survey and the recorder type. See the examples for how to get information for all surveys.
#'
#' @param SurveyName A character vector giving the name of the survey for which
#' you want to extract header information.
#' @param RecType A character vector giving the name of record type for which
#' you want to extract header information e.g. 'Classic', 'Classic-emmer', 'Classic-ketting', 'BioHab', 'ABS'.
#' @param con dbconnection with the database 'Cydonia' on the inbo-sql07-prd server
#'
#' @return A data.frame with variables RecordingGivid, Name, UserReference, LocationCode, Latitude, Longitude, Area, Length, Width, SurveyId, RecTypeID.
#'
#' @importFrom glue glue_sql
#' @importFrom DBI dbGetQuery
#' @importFrom assertthat assert_that
#'
#' @examples
#' con <- DBI::dbConnect(odbc::odbc(), .connection_string = "Driver=SQL Server;Server=inbo-sql07-prd.inbo.be,1433;Database=D0010_00_Cydonia;Trusted_Connection=Yes;")
#' SurveyName <- "OudeLanden_1979"
#' RecType <- "Classic"
#' Headerinfo <- read_iv_header_info_edb(SurveyName, RecType, con)
#' dbDisconnect(con)
#' rm(con)


read_iv_header_info_edb <- function(SurveyName, RecType, .con) {
  
  assert_that(is.character(SurveyName))
  assert_that(
    inherits(.con, "DBIConnection"),
    msg = "Er is geen connectie met de INBOVEG databank. Geef een connectie mee met de parameter .con" #nolint
  )
  
  dbGetQuery(.con, glue_sql(
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
      AND ivS.Name LIKE {SurveyName}
      AND ivREc.Name LIKE {RecType}",
      ivS.Name = SurveyName,
      ivRec.Name = RecType,
      .con = con))
  }
  
 
 