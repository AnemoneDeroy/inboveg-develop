#' @title Taxa and coverage per vegetation layer
#'
#' @description For the requested surveys, the coverage for each taxon and each vegetation
#' layer is provided.
#'
#' @param survey_name vector of char or NULL (default NULL), i.e. all surveys are taken into account
#' @param recording_type A character vector giving the name of record type for which
#' you want to extract header information e.g. 'Classic', 'Classic-emmer', 'Classic-ketting', 'BioHab', 'ABS'.
#' @param connection dbconnection with the database 'Cydonia' on the inbo-sql07-prd server
#' @param collect If FALSE (the default), a remote tbl object is returned.
#' This is like a reference to the result of the query but the full result of
#' the query is not brought into memory. If TRUE the full result of the query is
#' collected (fetched) from the database and brought into memory of the working
#' environment.
#' @param multiple If TRUE, survey_name can take a character vector with
#' multiple survey names that must match exactly. If FALSE (the default),
#' survey_name must be a single character string (one survey name) that can
#' include wildcarts to allow partial matches
#'
#' @return A remote tbl object (collect = FALSE) or a tibble dataframe (collect
#' = TRUE) with variables
#' 
#' @importFrom DBI dbSendQuery dbBind dbFetch dbClearResult
#' @importFrom assertthat assert_that
#' 
#' @importFrom glue glue_sql
#' @importFrom DBI dbGetQuery
#' @importFrom assertthat assert_that
#' @importFrom dplyr collect tbl sql
#' 
#' @export
#'
#' @examples
#' \dontrun{
#' connection <- connect_inbo_dbase("D0010_00_Cydonia")
#' coverage <- inboveg_coverage(con, survey_name = "Sigma_LSVI_2012")
#' coverage <- inboveg_coverage(con, recording_type = c('Classic',
#'     'Classic-emmer', 'Classic-ketting'), survey_name = c('Sigma_LSVI_2012'))
#'  dbDisconnect(con)
#' }

inboveg_coverage <- function(connection,
                             survey_name,
                             recording_type,
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
  
  if (missing(recording_type)) {
    recording_type <- "%"
  } else {
    assert_that(is.character(recording_type))
  }
  
  
sql_statement <- " SELECT ivRecording.RecordingGivid
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
  FROM dbo.ivRecTypeD
  INNER JOIN dbo.ivRecording ON ivRecording.RecTypeID = ivRecTypeD.ID
  INNER JOIN dbo.ivSurvey ON ivSurvey.Id = ivRecording.SurveyId
  LEFT JOIN dbo.ivRLLayer ON ivRLLayer.RecordingID = ivRecording.Id
  LEFT JOIN dbo.ivRLTaxonOccurrence ON
    ivRLTaxonOccurrence.LayerID = ivRLLayer.ID
  LEFT JOIN dbo.ivRLIdentification ON 
    ivRLIdentification.OccurrenceID = ivRLTaxonOccurrence.ID
  LEFT JOIN dbo.ivRLResources ON
    ivRLResources.ResourceGIVID = ivRLTaxonOccurrence.CoverageResource
  LEFT JOIN D0013_00_Futon.dbo.ftActionGroupList ON
    ftActionGroupList.ListName = ivRLResources.ListName
    COLLATE Latin1_General_CI_AI
  LEFT JOIN D0013_00_Futon.dbo.ftCoverValues ON
    ftCoverValues.ListGIVID = ftActionGroupList.ListGIVID
    COLLATE Latin1_General_CI_AI
    AND ftCoverValues.Code = [ivRLTaxonOccurrence].[CoverageCode]
    COLLATE Latin1_General_CI_AI
  WHERE ivRLIdentification.Preferred = 1
  AND ivRecTypeD.Name IN {recording_type}
  AND ivSurvey.Name IN {survey_name}
  ORDER BY ivRLLayer.LayerCode;
  "
sql_statement <- dbSendQuery(connection, sql_statement)
  dbBind(sql_statement, survey = survey_name)
  coverage <- dbFetch(sql_statement)
  dbClearResult(sql_statement)
  coverage
}
