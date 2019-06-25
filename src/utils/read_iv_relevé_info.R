#'   @title Query relevé information from INBOVEG
#'
#' @description This function queries the INBOVEG database for relevé information for a survey by the name of the survey. 
#'
#' @param SurveyName A character vector giving the name of the survey for which
#' you want to extract relevé information.
#' @param con dbconnection with the database 'Cydonia' on the inbo-sql07-prd server
#'
#' @return A data.frame with variables xxxx
#'
#' @importFrom glue glue_sql
#' @importFrom DBI dbGetQuery
#' @importFrom assertthat assert_that
#'
#' @examples
#' con <- DBI::dbConnect(odbc::odbc(), .connection_string = "Driver=SQL Server;Server=inbo-sql07-prd.inbo.be,1433;Database=D0010_00_Cydonia;Trusted_Connection=Yes;")
#' SurveyName <- "OudeLanden_1979"
#' Relevéinfo <- read_iv_relevé_info(SurveyName, con)
#' dbDisconnect(con)
#' rm(con)
#' 
#' 
#' 
con_Cydonia <- dbConnect(odbc::odbc(), .connection_string = "Driver=SQL Server;Server=inbo-sql07-prd.inbo.be,1433;Database=D0010_00_Cydonia;Trusted_Connection=Yes;")
con_Futon <- dbConnect(odbc::odbc(), .connection_string = "Driver=SQL Server;Server=inbo-sql07-prd.inbo.be,1433;Database=D0013_00_Futon;Trusted_Connection=Yes;")

read_iv_relevé_info <-  function(SurveyName, con_Cydonia, con_Futon) {
  dbGetQuery(con_Cydonia, con_Futon, glue_sql(
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
    FROM [dbo].[ftTaxon] ftTaxon
    INNER JOIN [dbo].[ftTaxonListItem] ftTLI ON ftTLI.TaxonGIVID = ftTaxon.TaxonGIVID
    LEFT JOIN (SELECT ftTaxonLI.TaxonListItemGIVID
    , ftTaxon.TaxonGIVID
    , ftTaxon.TaxonName
    , ftTaxon.TaxonQuickCode
    , ftAGL.ListName
    , ftTaxonLI.PreferedListItemGIVID
    FROM [dbo].[ftActionGroupList] ftAGL
    INNER JOIN [dbo].[ftTaxonListItem] ftTaxonLI ON ftTaxonLI.TaxonListGIVID = ftAGL.ListGIVID
    LEFT JOIN [dbo].[ftTaxon] ftTaxon ON ftTaxon.TaxonGIVID = ftTaxonLI.TaxonGIVID
    WHERE 1=1
    AND ftAGL.ListName = 'INBO-2011 Sci'
    ) GetSyn ON GetSyn.TaxonListItemGIVID = ftTLI.PreferedListItemGIVID
    WHERE ftTLI.TaxonListGIVID = 'TL2011092815101010'
    ) Synoniem on ivRL_Iden.TaxonFullText = Synoniem.TaxonFullText collate Latin1_General_CI_AI
    LEFT JOIN [dbo].[ivRLResources] ivRL_Res on ivRL_Res.ResourceGIVID = ivRL_Taxon.CoverageResource
    LEFT JOIN [dbo].[ftActionGroupList] ftAGL on ftAGL.ActionGroup = ivRL_Res.ActionGroup collate Latin1_General_CI_AI
    AND ftAGL.ListName = ivRL_Res.ListName collate Latin1_General_CI_AI
    LEFT JOIN [dbo].[ftCoverValues] ftCover on ftCover.ListGIVID = ftAGL.ListGIVID
    AND ivRL_Taxon.CoverageCode = ftCover.Code collate Latin1_General_CI_AI
    WHERE ivR.NeedsWork = 0
    AND ivRL_Iden.Preferred = 1
    AND ivS.Name LIKE {SurveyName}",
    ivS.Name = SurveyName,
    .con = con_Cydonia, 
    .con2 = con_Futon))
}

OudeLanden <- Vegetation_info("OudeLanden_1979", con_Cydonia, con_Futon)
