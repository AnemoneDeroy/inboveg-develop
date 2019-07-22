library(tidyverse)
library(DBI)
library(glue)
library(knitr)
library(odbc)
library(assertthat)
library(inborutils)

con <- connect_inbo_dbase("D0010_00_Cydonia")
con_futon <- connect_inbo_dbase("D0013_00_Futon")

## opbouw vanaf de queries uit AccessFront

# TEST <- 
# dbGetQuery(con, 
#   "SELECT RecordingGIVID.ivRecording
#           , ivRecording.UserReference
#           , ivRecording.Observer
#           , ivRLQualifier.QualifierType
#           , ivRLQualier.QualierCode
#           , qry_01ACvalues.oms
#           , ivRLQualier_1.QualierCode
#           , qry_01ACvalues_1.oms
#           , ivRLQualier_2.QualierCode
#           , qry_01ACvalues_2.oms
#           , ivRLQualifier.Elucidation
#           , ivRLQualifier.NotSure
#           , ivRLQualier.ParentId
#  FROM ivRecording 
#  LEFT JOIN ivRLQualifier on Recording.ID = ivRecording.Id
#  LEFT JOIN ivRLQualifier AS ivRLQualifier_1 ON ivRLQualifier.ID = ivRLQualier_1.ParentID
#  LEFT JOIN ivRLQualifier AS ivRLQualifier_2 ON ivRLQualifier_1.ID = ivRLQualier_2.ParentID
# -- hier komt qry_01ACValues
#  LEFT JOIN (
#   SELECT
#     ivRLResources.ResourceGIVID
#     , ivRLResources.ActionGroup
#     , ivRLResources.ListName
#     , ftValues_union.Code
#     , ftValues_union.Description
#   FROM ivRLResources 
#   LEFT JOIN D0013_00_Futon.dbo.ftActionGroupList ON 
#     ivRLResources.ListName = D0013_00_Futon.dbo.ftActionGroupList.ListName collate Latin1_General_CI_AI
#   AND ivRLResources.ActionGroup = D0013_00_Futon.dbo.ftActionGroupList.ActionGroup collate Latin1_General_CI_AI

# -- hier begint de union van alle AC-value tabellen  
#   LEFT JOIN (


# opbouw union-query op basis van tip Hans VC 

Union <- dbGetQuery(con, "SELECT
                  ftValues_union.Code
                  , ftValues_union.Description
                  , ftValues_union.ListGIVID
    FROM (((( SELECT 
                ftQualifierValues.ftQualifierValuesId
                , ftQualifierValues.ListGIVID
                , ftQualifierValues.Code
                , ftQualifierValues.Description
                , ftQualifierValues.Elucidation
                , ftQualifierValues.SortCode
                , NULL AS ftQualifierValues.ftDQualifierValuesId
                , NULL AS ftQualifierValues.DrillDownGIVID
            FROM ftQualifierValues)
              UNION (SELECT 
                        NULL AS ftQualifierValuesId
                        , ftDQualifierValues.ListGIVID
                        , ftDQualifierValue.Code
                        , ftDQualifierValues.Description
                        , ftDQualifierValues.Elucidation
                        , ftDQualifierValues.SortCode
                        , ftDQualifierValues.ftDQualifierValuesId
                        , ftDQualifierValues.DrillDownGIVID
                    FROM ftDQualifierValues)) dbplyr_001
            UNION (dbplyr_001, (SELECT
                        NULL AS ftQualifierValues.ftQualifierValuesId
                        , ftAbiotiekValues.ListGIVID
                        , ftAbiotiekValues.Code
                        , ftAbiotiekValues.Description
                        , ftAbiotiekValues.Elucidation
                        , ftAbiotiekValues.SortCode
                  FROM ftAbiotiekValues))) dbplyr_002
            UNION (dbplyr_002, (SELECT
                                NULL AS ftQualifierValues.ftQualifierValuesId
                                , ftBWKValues.ListGIVID
                                , ftBWKValues.Code
                                , ftBWKValues.Description
                                , ftBWKValues.Elucidation
                                , ftBWKValues.SortCode
                          FROM ftBWKValues)) ftValues_union")
#" andere poging

Union <- (("SELECT 
                    ftQualifierValues.ftQualifierValuesId
                    , ftQualifierValues.ListGIVID
                    , ftQualifierValues.Code
                    , ftQualifierValues.Description
                    , ftQualifierValues.Elucidation
                    , ftQualifierValues.SortCode
                    , NULL AS ftQualifierValues.ftDQualifierValuesId
                    , NULL AS ftQualifierValues.DrillDownGIVID
                    FROM ftQualifierValues)
            UNION (SELECT 
                    NULL AS ftQualifierValuesId
                    , ftDQualifierValues.ListGIVID
                    , ftDQualifierValue.Code
                    , ftDQualifierValues.Description
                    , ftDQualifierValues.Elucidation
                    , ftDQualifierValues.SortCode
                    , ftDQualifierValues.ftDQualifierValuesId
                    , ftDQualifierValues.DrillDownGIVID
                    FROM ftDQualifierValues)")) 


dbplyr_001
                    UNION (dbplyr_001, (SELECT
                    NULL AS ftQualifierValues.ftQualifierValuesId
                    , ftAbiotiekValues.ListGIVID
                    , ftAbiotiekValues.Code
                    , ftAbiotiekValues.Description
                    , ftAbiotiekValues.Elucidation
                    , ftAbiotiekValues.SortCode
                    FROM ftAbiotiekValues))) dbplyr_002
                    UNION (dbplyr_002, (SELECT
                    NULL AS ftQualifierValues.ftQualifierValuesId
                    , ftBWKValues.ListGIVID
                    , ftBWKValues.Code
                    , ftBWKValues.Description
                    , ftBWKValues.Elucidation
                    , ftBWKValues.SortCode
                    FROM ftBWKValues)) ftValues_union")



) ftValues_union ON D0013_00_Futon.dbo.ftActionGroupList.ListGIVID = ftValues_union.ListGIVID
        WHERE ivRLResources.ResourceGIVID LIKE 'RS2014091211335947'
-- query AC - values
  ) qry01_ACValues ON ivRLQualifier.QualifierCode = qry_01ACvalues.Code
         AND ivRLQualifier.QualifierResource = qry_01ACvalues.ResourceGIVID 
  LEFT JOIN qry_01ACvalues AS qry_01ACvalues_1 ON 
        ivRLQualifier_1.QualifierCode = qry_01ACvalues_1.Code
        AND ivRLQualifier_1.QualifierResource = qry_01ACvalues_1.ResourceGIVID 
  LEFT JOIN qry_01ACvalues AS qry_01ACvalues_2 ON 
  ivRLQualifier_2.QualifierCode = qry_01ACvalues_2.Code
  AND ivRLQualifier_2.QualifierResource = qry_01ACvalues_2.ResourceGIVID
  WHERE (((ivRLQualifier.ParentID) Is Null))
  ORDER BY ivRecording.UserReference, ivRLQualifier.QualifierType, ivRLQualifier.QualifierCode;"
  ,.con = con)


