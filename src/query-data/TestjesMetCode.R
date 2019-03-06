library(tidyverse)
library(DBI)
library(glue)
library(knitr)
library(odbc)

con <- dbConnect(odbc::odbc(), .connection_string = "Driver=SQL Server;Server=inbo-sql07-prd.inbo.be,1433;Database=D0010_00_Cydonia;Trusted_Connection=Yes;")

# survey <- "Niche"
# string <- "MILKLIM"
# owner <- "Els De Bie"

survey_info <- function(con, survey) {
  dbGetQuery(con, glue_sql(
    "SELECT
             ivS.Id
            , ivS.Name
            , ivS.Description
            , ivS.Owner
            , ivS.creator
    FROM [dbo].[ivSurvey] ivS
    WHERE ivS.Name LIKE {survey}", 
    ivS.Name = survey))
}


Test <- survey_info(con, "OudeLanden_1979")