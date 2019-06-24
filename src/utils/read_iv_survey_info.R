#' @title Query survey information from INBOVEG
#'
#' @description This function queries the INBOVEG database for survey information (metadata about surveys) for one or more survey(s) by the name of the survey. See the examples for how to get information for all surveys.
#'
#' @param survey A character vector giving the names of the surveys for which
#' you want to extract survey information.
#' @param con dbconnection with the database 'Cydonia' on the inbo-sql07-prd server
#'
#' @return A data.frame with variables Id, Name, Description, Owner and Creator.
#'
#' @importFrom glue glue_sql
#' @importFrom DBI dbGetQuery
#' @importFrom assertthat assert_that
#'
#' @examples
#' con <- DBI::dbConnect(odbc::odbc(), .connection_string = "Driver=SQL Server;Server=inbo-sql07-prd.inbo.be,1433;Database=D0010_00_Cydonia;Trusted_Connection=Yes;")
#' survey <- "OudeLanden_1979"
#' Surveyinfo <- read_iv_survey_info(survey, con)
#' AlleSurveys <- read_iv_survey_info(survey = "%", .con = con)
#' dbDisconnect(con)
#' rm(con)

read_iv_survey_info <- function(survey, .con) {

  assert_that(is.character(survey))
  assert_that(
    inherits(.con, "DBIConnection"),
    msg = "Er is geen connectie met de INBOVEG databank. Geef een connectie mee met de parameter .con" #nolint
  )


  dbGetQuery(con, glue_sql(
    "SELECT
    ivS.Id
    , ivS.Name
    , ivS.Description
    , ivS.Owner
    , ivS.creator
    FROM [dbo].[ivSurvey] ivS
    WHERE ivS.Name LIKE {survey}",
    .con = con ))
}
