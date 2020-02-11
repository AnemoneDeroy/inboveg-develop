---
title: "Tutorial on how to retrieve data from the INBOVEG database"
author: "Els De Bie, Hans Van Calster & Jo Loos"
date: "1 maart 2019 (updated 2020-02-11)"
categories: databases queries
tags: database 
output: 
  md_document:
    preserve_yaml: true
    toc: true
    df_print: kable
---

-   [Introduction](#introduction)
-   [Aim](#aim)
-   [Packages and connection](#packages-and-connection)
-   [Functionality](#functionality)
    -   [Survey information](#survey-information)
        -   [Examples](#examples)
    -   [Recording information](#recording-information)
        -   [Examples](#examples-1)
    -   [Header information](#header-information)
        -   [Examples](#examples-2)
    -   [Classification information](#classification-information)
        -   [Examples](#examples-3)
    -   [Qualifiers information](#qualifiers-information)
        -   [Examples](#examples-4)
    -   [More complex queries](#more-complex-queries)
        -   [Examples](#examples-5)
-   [Closing the connection](#closing-the-connection)

Introduction
============

The Flemish vegetation database, INBOVEG, is an application developed to
provide a repository of relevés and makes the relevés available for
future use.

INBOVEG supports different types of recordings: BioHab recordings
(protocol of Natura 2000 monitoring) and the classic relevés. The
classic relevés can stand alone, be an element of a collection or
element of a chain where the linkage is used to give information about
the relative position of recording within a series. Ample selection and
export functions toward analysis tools are provided. It also provides
standardized lists of species, habitats, life forms, scales etc.
Original observations are preserved and a full history of subsequent
identifications is saved.

Aim
===

In this tutorial we make functions available to query data directly from
the INBOVEG SQL-server database. This to avoid writing your own queries
or to copy/paste them from the access-frontend for INBOVEG.

We have provided functions to query

-   survey (INBOVEG-projects)

-   recordings (vegetation relevés)

-   metadata of recordings (header info)

-   classification (Natura2000 or local classification like BWK)

-   qualifiers (management and site characteristics)

Packages and connection
=======================

In order to run the functionalities, some R packags need to be
installed.

The following packages are needed to run this code:

-   glue

-   DBI

-   assertthat

-   dplyr

Loading the functionality can be done by loading the `inborutils`
package:

-   inborutils

You can install inborutils from github with:
install.packages("devtools")
devtools::install\_github("inbo/inborutils")

Be sure you have reading-rights for CYDONIA otherwise place an ICT-call
(<ict.helpdesk@inbo.be>)

    library(glue)
    library(DBI)
    library(assertthat)
    library(dplyr)
    library(inborutils)

The following R-code can be used to establish a connection to INBOVEG by
means of a connection string:

<!--better to use a connection string than dsn. 
dsn requires extra steps and settings in windows odbc manager-->
    connection <- dbConnect(odbc::odbc(), .connection_string = "Driver=SQL Server;Server=inbo-sql07-prd.inbo.be,1433;Database=D0010_00_Cydonia;Trusted_Connection=Yes;")

Or using dbconnection of the inborutils-package with the database
'Cydonia' on the inbo-sql07-prd server:

    con <- connect_inbo_dbase("D0010_00_Cydonia")

Functionality
=============

Survey information
------------------

The function `inboveg_survey` queries the INBOVEG database for survey
information (metadata about surveys) for one or more survey(s) by the
name of the survey.

### Examples

Three examples are given, this can be used as base to continue selecting
the wanted data

    # get information of a specific survey and collect data (only 10 rows are shown)
    survey_info <- inboveg_survey(con, 
                                  survey_name = "OudeLanden_1979", 
                                  collect = TRUE)

    survey_info

<table>
<thead>
<tr class="header">
<th align="right">Id</th>
<th align="left">Name</th>
<th align="left">Description</th>
<th align="left">Owner</th>
<th align="left">creator</th>
</tr>
</thead>
<tbody>
<tr class="odd">
<td align="right">172</td>
<td align="left">OudeLanden_1979</td>
<td align="left">Verlinden A, Leys G en Slembrouck J (1979) Groeiplaatsen van Ophioglossum vulgatum en Orphys apifera bij Antwerpen</td>
<td align="left">NA</td>
<td align="left">els_debie</td>
</tr>
</tbody>
</table>

Get information of all surveys. This time we will not use
`collect = TRUE`, which will return a lazy query:

    allsurveys <- inboveg_survey(con)

    allsurveys

<table>
<thead>
<tr class="header">
<th align="right">Id</th>
<th align="left">Name</th>
<th align="left">Description</th>
<th align="left">Owner</th>
<th align="left">creator</th>
</tr>
</thead>
<tbody>
<tr class="odd">
<td align="right">1</td>
<td align="left">ZLB</td>
<td align="left">Opnamen Zandleembrabant en omgeving</td>
<td align="left">Gisèle Weyembergh</td>
<td align="left">luc_vanhercke</td>
</tr>
<tr class="even">
<td align="right">2</td>
<td align="left">Sigma_Biohab_2012</td>
<td align="left">Biohab opnames in Sigmagebieden vanaf2012</td>
<td align="left">Wim Mertens</td>
<td align="left">wim_mertens</td>
</tr>
<tr class="odd">
<td align="right">3</td>
<td align="left">Sigma_LSVI_2012</td>
<td align="left">Perceelsopnamen van volledige soortenlijst met Londo-bedekking; + ev.structuurkenmerken</td>
<td align="left">wim mertens</td>
<td align="left">wim_mertens</td>
</tr>
<tr class="even">
<td align="right">4</td>
<td align="left">MILKLIM_Alopecurion</td>
<td align="left">Standplaatsonderzoek graslanden behorende tot Alopecurion (6510hus en 6510hua)</td>
<td align="left">MILKLIM</td>
<td align="left">maud_raman</td>
</tr>
<tr class="odd">
<td align="right">5</td>
<td align="left">MILKLIM_WZ_AalstTeralfene</td>
<td align="left">Opnamen van PQ's in regio Aalst en Teralfene (Dendervallei), in het kader van de waterpeilverlaging van de Dender. Binnen raamovereenkomst INBO-W&amp;Z.</td>
<td align="left">MILKLIM</td>
<td align="left">floris_vanderhaeghe</td>
</tr>
<tr class="even">
<td align="right">6</td>
<td align="left">MILKLIM_Hei(schraal)herstel</td>
<td align="left">PQ's in kader van onderzoek naar de effectiviteit van natuurherstelmaatregelen in heide-achtige systemen</td>
<td align="left">MILKLIM</td>
<td align="left">floris_vanderhaeghe</td>
</tr>
<tr class="odd">
<td align="right">7</td>
<td align="left">MILKLIM_Heide</td>
<td align="left">Standplaatsonderzoek heide</td>
<td align="left">MILKLIM</td>
<td align="left">jan_wouters</td>
</tr>
<tr class="even">
<td align="right">8</td>
<td align="left">MILKLIM_W&amp;Z_Leiebermen_2010_2013</td>
<td align="left">Evaluatie maaibeheer Leiebermen gedurende de periode 2012_2013</td>
<td align="left">MILKLIM</td>
<td align="left">maud_raman</td>
</tr>
<tr class="odd">
<td align="right">9</td>
<td align="left">MILKLIM_W&amp;Z_Geraardsbergen</td>
<td align="left">Vegetatieopnames in het kader van gebiedsverkenning naar aanleiding van geplande peilverlaging Dender</td>
<td align="left">MILKLIM</td>
<td align="left">luc_vanhercke</td>
</tr>
<tr class="even">
<td align="right">10</td>
<td align="left">MILKLIM_Heischraal2012</td>
<td align="left">Vegetatieopnames in het kader van standplaatsonderzoek - heischrale graslanden</td>
<td align="left">MILKLIM</td>
<td align="left">cecile_herr</td>
</tr>
<tr class="odd">
<td align="right">11</td>
<td align="left">MILKLIM_W&amp;Z_Varia</td>
<td align="left">Losse opnamen in het kader van kleine opdrachtjes voor W&amp;Z (adviezen, nota's, korte inventarisaties). Binnen raamovereenkomst INBO-W&amp;Z.</td>
<td align="left">MILKLIM</td>
<td align="left">floris_vanderhaeghe</td>
</tr>
<tr class="even">
<td align="right">12</td>
<td align="left">MILKLIM_W&amp;Z_Bermen_AfleidingskanaalLeie</td>
<td align="left">Ecologische opvolging van bermvegetatie</td>
<td align="left">MILKLIM</td>
<td align="left">els_debie</td>
</tr>
<tr class="odd">
<td align="right">13</td>
<td align="left">AZ_2006</td>
<td align="left">Relevés Arnout Zwaenepoel - Bundel 2006; Kust, De Langdonken...</td>
<td align="left">Arnout Zwaenepoel</td>
<td align="left">els_debie</td>
</tr>
<tr class="even">
<td align="right">14</td>
<td align="left">MILKLIM_W&amp;Z_OeversLeie</td>
<td align="left">Oeveropnamen langs de Leie ter evaluatie van oevermaatregelen genomen ikv Seine Schelde</td>
<td align="left">Maud Raman</td>
<td align="left">luc_vanhercke</td>
</tr>
<tr class="odd">
<td align="right">15</td>
<td align="left">MILKLIM_W&amp;Z_Leiemeanders</td>
<td align="left">Opvolging van PQ's langs meanders van de Leie in het kader van het Seine-Schelde-project. Valt onder raamovereenkomst INBO-W&amp;Z.</td>
<td align="left">MILKLIM</td>
<td align="left">floris_vanderhaeghe</td>
</tr>
<tr class="even">
<td align="right">16</td>
<td align="left">MILKLIM_Overstroming</td>
<td align="left">Vegetatieopnames gemaakt tijdens 2011 voor het ANB-project 'Verzamelen van basiskennis en ontwikkeling van een beoordelings- of afwegingskader voor de ecologische effectanalyse van overstromingen.</td>
<td align="left">Els De Bie</td>
<td align="left">els_debie</td>
</tr>
<tr class="odd">
<td align="right">17</td>
<td align="left">RobinG_LosseOpnames</td>
<td align="left">Opnames gemaakt door Robin Guelinckx, niet in kader van project.</td>
<td align="left">Robin Guelinckx</td>
<td align="left">els_debie</td>
</tr>
<tr class="even">
<td align="right">18</td>
<td align="left">Sigma_PQ</td>
<td align="left">pq opnames in het kader van Sigmamonitoring</td>
<td align="left">Wim Mertens</td>
<td align="left">wim_mertens</td>
</tr>
<tr class="odd">
<td align="right">19</td>
<td align="left">AZ_2012</td>
<td align="left">Relevés Arnout Zwaenepoel - Bundel 2012</td>
<td align="left">Arnoud Zwaenepoel</td>
<td align="left">els_debie</td>
</tr>
<tr class="even">
<td align="right">20</td>
<td align="left">MILKLIM_OverstromingHoeleden</td>
<td align="left">Resultaten uit de thesis van Mikaël Maes - UGent - 2013</td>
<td align="left">INBO</td>
<td align="left">els_debie</td>
</tr>
<tr class="odd">
<td align="right">21</td>
<td align="left">Schelde-estuarium</td>
<td align="left">Opnames in gebieden langs Schelde-estuarium, losse en pq's.</td>
<td align="left">Bart Vandevoorde</td>
<td align="left">bart_vandevoorde</td>
</tr>
<tr class="even">
<td align="right">23</td>
<td align="left">MILKLIM_BlauwVeldrusgrasland</td>
<td align="left">Standplaatsonderzoek veldrusgrasland, blauwgrasland en heischraal grasland</td>
<td align="left">MILKLIM</td>
<td align="left">jan_wouters</td>
</tr>
<tr class="odd">
<td align="right">24</td>
<td align="left">StandaardClassic</td>
<td align="left">een prototype voor klassieke vegetatieopnames, met soortenlijst en bedekkingen per structuurlaag.</td>
<td align="left"></td>
<td align="left">els_debie</td>
</tr>
<tr class="even">
<td align="right">25</td>
<td align="left">StandaardClassisPQ</td>
<td align="left">een prototype van vegetatieopnames, met soortenlijst en bedekkingen per structuurlaag, gelinkt aan permanent quadrant.</td>
<td align="left">NA</td>
<td align="left">els_debie</td>
</tr>
<tr class="odd">
<td align="right">26</td>
<td align="left">StandaardClassic_Peilbuis</td>
<td align="left">een prototype voor klassieke vegetatieopnames, met soortenlijst en bedekking per structuurlaag, gelinkt aan peilbuis (of ander abiotische meetinstrument)</td>
<td align="left">NA</td>
<td align="left">els_debie</td>
</tr>
<tr class="even">
<td align="right">27</td>
<td align="left">StandaardBiohab</td>
<td align="left">een prototype voor BIOHAB -vegetatieopnames (Natura2000 monitoringsprotocol)</td>
<td align="left">NA</td>
<td align="left">els_debie</td>
</tr>
<tr class="odd">
<td align="right">28</td>
<td align="left">Overstromingsgebieden_Demer_1997</td>
<td align="left">Studieopdracht - Botanische inventarisatie van een aantal overstromende natuurterreinen in het Demerbekken, 1998</td>
<td align="left">INBO</td>
<td align="left">els_debie</td>
</tr>
<tr class="even">
<td align="right">29</td>
<td align="left">MILKLIM_W&amp;Z_Bermen_KanaalGentBrugge</td>
<td align="left">Opvolging van de bermvegetatie van het Kanaal Gent-Brugge; in opdracht van W&amp;Z</td>
<td align="left">MILKLIM</td>
<td align="left">els_debie</td>
</tr>
<tr class="odd">
<td align="right">30</td>
<td align="left">VandenBerghen1946_NotesBotaniqueBrabançonne</td>
<td align="left">Vegetatieopnames gemaakt door Cyriel Vanden Berghe in 1945, II Les marécages alcalins. Trefwoorden: sol sec; Molinietum caerulea</td>
<td align="left">Cyriel Vanden Berghen</td>
<td align="left">els_debie</td>
</tr>
<tr class="even">
<td align="right">31</td>
<td align="left">VandenBerghen1951_PrairiesMolinia</td>
<td align="left">Vegetatieopnames gemaakt door Cyriel Vanden Berghen in 1941-. Trefwoorden: Molinietum coeruleae atlanticum; Prairie tourbeuse à proximité du Grand Schijn</td>
<td align="left">Cyriel Vanden Berghen</td>
<td align="left">els_debie</td>
</tr>
<tr class="odd">
<td align="right">32</td>
<td align="left">NICHE Vlaanderen</td>
<td align="left">Opnames gemaakt in kader van het NICHE Vlaanderen project (2002 - 2006). Hier enkel veldwerk gegevens, literatuurgegevens zijn hier niet opgenomen.</td>
<td align="left">INBO</td>
<td align="left">els_debie</td>
</tr>
<tr class="even">
<td align="right">33</td>
<td align="left">MILKLIM_LevelII_BraunBlanquet</td>
<td align="left">Bosopnames in kader van het Level II bos-monitoringsproject</td>
<td align="left">INBO</td>
<td align="left">els_debie</td>
</tr>
<tr class="odd">
<td align="right">34</td>
<td align="left">MILKLIM_LevelII_Londo</td>
<td align="left">Bosopnames in kader van LevelII-monitoring</td>
<td align="left">INBO</td>
<td align="left">els_debie</td>
</tr>
<tr class="even">
<td align="right">35</td>
<td align="left">MILKLIM_W&amp;Z_vooroevers_KanaalGentBrugge</td>
<td align="left">Opvolging van de vegetatie in de vooroevers langs het Kanaal Gent-Brugge, in opdracht van W&amp;Z</td>
<td align="left">MILKLIM</td>
<td align="left">andy_vankerckvoorde</td>
</tr>
<tr class="odd">
<td align="right">36</td>
<td align="left">AssociationsTourbeusesEnCampine</td>
<td align="left">Duvigneaud en Vanden Berghen 1945</td>
<td align="left"></td>
<td align="left">jan_wouters</td>
</tr>
<tr class="even">
<td align="right">37</td>
<td align="left">Sigma-2008/2012-BioHab</td>
<td align="left">Opnames gemaakt van 2008 t/m 2012 (import uit cslocal db)</td>
<td align="left">NA</td>
<td align="left">wim_mertens</td>
</tr>
<tr class="odd">
<td align="right">38</td>
<td align="left">Sigma-2008/2012-Classic</td>
<td align="left">Sigma opnames uit de periode 2008/2012; de Opnamesoorten (import uit cslocal db</td>
<td align="left">NA</td>
<td align="left">wim_mertens</td>
</tr>
<tr class="even">
<td align="right">39</td>
<td align="left">BIOMON_HEIDETYPOLOGIE_LONDO</td>
<td align="left">opnames verzameld ikv typologie en sleutel heidevegetaties s.l.</td>
<td align="left">BIOMON</td>
<td align="left">patrik_oosterlynck</td>
</tr>
<tr class="odd">
<td align="right">40</td>
<td align="left">BIOMON_HEIDE_TANSLEY</td>
<td align="left">opnames ikv typologie en sleutel voor heidevegetaties s.l. - Tansley-schaal- IHD</td>
<td align="left">BIOMON</td>
<td align="left">els_debie</td>
</tr>
<tr class="even">
<td align="right">41</td>
<td align="left">BIOMON_HEIDEKWALITEIT</td>
<td align="left">Opnames ikv meetnet habitatkwaliteit voor de subset heidehabitats</td>
<td align="left">INBO</td>
<td align="left">patrik_oosterlynck</td>
</tr>
<tr class="odd">
<td align="right">42</td>
<td align="left">BIOMON_Cratoneurion</td>
<td align="left">Mosopnames van sites met kalktufvorming.</td>
<td align="left">INBO</td>
<td align="left">patrik_oosterlynck</td>
</tr>
<tr class="even">
<td align="right">43</td>
<td align="left">MILKLIM_pilootheidebekalking</td>
<td align="left">Opvolging van pilootexperimenten heidebekalking (opnameninvoer door terreinbeheerders)</td>
<td align="left">MILKLIM</td>
<td align="left">floris_vanderhaeghe</td>
</tr>
<tr class="odd">
<td align="right">45</td>
<td align="left">Ijzermonding 2013</td>
<td align="left">vegetatie-opnames in het kader van de master-thesis van Pieter-Jan D'hondt (UGent).</td>
<td align="left">Pieter-Jan D'hondt</td>
<td align="left">pieterjan_dhondt</td>
</tr>
<tr class="even">
<td align="right">46</td>
<td align="left">AlnoPadion-AlnionIncanae</td>
<td align="left">Onderzoek naar abiotische standplaatsvereisten van beekbegeleidende bosgemeenschappen - 2004</td>
<td align="left">INBO</td>
<td align="left">els_debie</td>
</tr>
<tr class="odd">
<td align="right">47</td>
<td align="left">ECODIV_BovenscheldeLangemeersen_2008</td>
<td align="left">NA</td>
<td align="left">INBO</td>
<td align="left">els_debie</td>
</tr>
<tr class="even">
<td align="right">48</td>
<td align="left">BELAIR vegetation relevés 2013</td>
<td align="left">Vegetation relevés in the BELAIR study sites (Belgian remote sensing supersites): Zwin, IJzermonding, Lage Moere van Meetkerke, Zoniënwoud,...</td>
<td align="left">Jeroen Vanden Borre</td>
<td align="left">jeroen_vandenborre</td>
</tr>
<tr class="odd">
<td align="right">49</td>
<td align="left">Loots2008_VegetatiewijzingenLiereman1983-2007</td>
<td align="left">Vergelijking opnames van 1983 en 2007 op basis van DCA. Ellenbergwaarden worden gebruikt om eventuele wijzigingen te helpen verklaren.</td>
<td align="left">Marloes Loots, Jan Wouters</td>
<td align="left">jan_wouters</td>
</tr>
<tr class="even">
<td align="right">50</td>
<td align="left">KBR-veentranslocatie</td>
<td align="left">Opnames van PQ's in de experimentele veentranslocatiesite in KBR</td>
<td align="left">Bart Vandevoorde</td>
<td align="left">bart_vandevoorde</td>
</tr>
<tr class="odd">
<td align="right">51</td>
<td align="left">CultuurgraslandTypologie</td>
<td align="left">Demolder, H.; Adams, Y.; Paelinckx, D. (2003). Typologie en beheer van soortenrijke cultuurgraslanden.Rapporten van het instituut voor natuurbehoud, 2003(01). Instituut voor Natuurbehoud: Brussel. 157 pp.,</td>
<td align="left">INBO</td>
<td align="left">els_debie</td>
</tr>
<tr class="even">
<td align="right">52</td>
<td align="left">Ecosysteemvisie - Kalkense Meersen</td>
<td align="left">Opmaak van een ontwerp-ecosysteemvisie voor Kalkense meersen In opdracht van Afdeling Natuur, AMINAL. (INBO-bib: 574 DEGE 2004 )</td>
<td align="left">ANB</td>
<td align="left">els_debie</td>
</tr>
<tr class="odd">
<td align="right">53</td>
<td align="left">ABS-BRUGGE2004</td>
<td align="left">West-Vlaanderen 2004 (Inventarisatie Autochtone Bomen en Struiken)</td>
<td align="left">Kristine Vander Mijnsbrugge</td>
<td align="left">luc_vanhercke</td>
</tr>
<tr class="even">
<td align="right">54</td>
<td align="left">Het Vinne - ecohydrologische studie</td>
<td align="left">De Wilde M, De Becker P, Huybrechts W. (1999) Ecohydrologische studie van het vinne Rapporten van het instituut voor natuurbehoud, Instituut voor Natuurbehoud (Brussel)</td>
<td align="left">INBO</td>
<td align="left">els_debie</td>
</tr>
<tr class="odd">
<td align="right">55</td>
<td align="left">Het Rodebos - ecohydrologische studie</td>
<td align="left">Vercoutere B.(1995) Eco-hydrologische studie van het Rodebos. Thesis Katholieke Universiteit Leuven (KUL) (Leuven)</td>
<td align="left">KULeuven</td>
<td align="left">els_debie</td>
</tr>
<tr class="even">
<td align="right">56</td>
<td align="left">Baggergronden - hergebruik</td>
<td align="left">Mertens J, Piesschaert F (2005) Hergebruik van baggerspecie in landschapsdijken. Risico’s, ontwikkelingsmogelijkheden en beheer van dijken uit brak baggerslib. Wetenschappelijk onderzoek in opdracht van Port of Antwerp.</td>
<td align="left">INBO</td>
<td align="left">els_debie</td>
</tr>
<tr class="odd">
<td align="right">57</td>
<td align="left">GOG_KBR_2000</td>
<td align="left">Vegetatiekartering van het gecontroleerd overstromingsgebied (GOG) in Kruibeke</td>
<td align="left">INBO</td>
<td align="left">els_debie</td>
</tr>
<tr class="even">
<td align="right">58</td>
<td align="left">SlikkenSchorren_Het Zwin</td>
<td align="left">Van Den Balck E (1994)Vegetatiekundige &amp; Ecologische Studie van de Slikken &amp; Schorren in het Zwin (Knokke-Heist, West-Vlaanderen) - Thesis RUGent</td>
<td align="left">UGent</td>
<td align="left">els_debie</td>
</tr>
<tr class="odd">
<td align="right">59</td>
<td align="left">Niet-getij-gebonden Zeeschelde</td>
<td align="left">Van den Balck E, Hoffmann M en Meire P (1998) De terrestrische flora en vegetatie van het niet-getijbeïnvloede deel van het alluvium van de Zeeschelde.</td>
<td align="left">INBO</td>
<td align="left">els_debie</td>
</tr>
<tr class="even">
<td align="right">60</td>
<td align="left">RodeBosmier - vegetatieopnames</td>
<td align="left">Decock,L. 2006 Rode bosmieren (Formica s.str.) en Coccinella magnifica in West-Vlaanderen: inventarisatie, habitatpreferentie en beheer. Licentiaatsverhandeling UGent, Gent.</td>
<td align="left">INBO</td>
<td align="left">els_debie</td>
</tr>
<tr class="odd">
<td align="right">61</td>
<td align="left">ABS-Antw2002</td>
<td align="left">Antwerpen 2002 (Inventarisatie Autochtone Bomen en Struiken)</td>
<td align="left">Kristine Vander Mijnsbrugge</td>
<td align="left">luc_vanhercke</td>
</tr>
<tr class="even">
<td align="right">62</td>
<td align="left">ABS-GENT 99-4</td>
<td align="left">Gent en omgeving 1999 (Inventarisatie Autochtone Bomen en Struiken)</td>
<td align="left">Kristine Vander Mijnsbrugge</td>
<td align="left">luc_vanhercke</td>
</tr>
<tr class="odd">
<td align="right">63</td>
<td align="left">ABS-GROE2007</td>
<td align="left">Groenendaal 2007 (Inventarisatie Autochtone Bomen en Struiken)</td>
<td align="left">Kristine Vander Mijnsbrugge</td>
<td align="left">luc_vanhercke</td>
</tr>
<tr class="even">
<td align="right">64</td>
<td align="left">ABS-HAS2000</td>
<td align="left">Hasselt 2000 (Inventarisatie Autochtone Bomen en Struiken)</td>
<td align="left">Kristine Vander Mijnsbrugge</td>
<td align="left">luc_vanhercke</td>
</tr>
<tr class="odd">
<td align="right">66</td>
<td align="left">ABS-OVL 03/04</td>
<td align="left">Oost-Vlaanderen 2003-2004 (Inventarisatie Autochtone Bomen en Struiken)</td>
<td align="left">Kristine Vander Mijnsbrugge</td>
<td align="left">luc_vanhercke</td>
</tr>
<tr class="even">
<td align="right">67</td>
<td align="left">ABS-VL 97-1</td>
<td align="left">Ecologische Impulsgebieden 1997 (Inventarisatie Autochtone Bomen en Struiken)</td>
<td align="left">Kristine Vander Mijnsbrugge</td>
<td align="left">luc_vanhercke</td>
</tr>
<tr class="odd">
<td align="right">68</td>
<td align="left">ABS-VL 98-1 VA</td>
<td align="left">Vlaamse Ardennen 1998 (Inventarisatie Autochtone Bomen en Struiken)</td>
<td align="left">Kristine Vander Mijnsbrugge</td>
<td align="left">luc_vanhercke</td>
</tr>
<tr class="even">
<td align="right">69</td>
<td align="left">ABS-Voeren 06-07</td>
<td align="left">Voeren 2006-2007 (Inventarisatie Autochtone Bomen en Struiken)</td>
<td align="left">Kristine Vander Mijnsbrugge</td>
<td align="left">luc_vanhercke</td>
</tr>
<tr class="odd">
<td align="right">70</td>
<td align="left">ABS-Antw2012</td>
<td align="left">Antwerpen 2012 Bijkomende opnames (Inventarisatie Autochtone Bomen en Struiken)</td>
<td align="left">Kristine Vander Mijnsbrugge</td>
<td align="left">luc_vanhercke</td>
</tr>
<tr class="even">
<td align="right">71</td>
<td align="left">ABS-LIM2012</td>
<td align="left">Limburg 2012 Bijkomende opnames (Inventarisatie Autochtone Bomen en Struiken)</td>
<td align="left">Kristine Vander Mijnsbrugge</td>
<td align="left">luc_vanhercke</td>
</tr>
<tr class="odd">
<td align="right">72</td>
<td align="left">ABS-OVL2011</td>
<td align="left">Oost-Vlaanderen 2011 Bijkomende opnames (Inventarisatie Autochtone Bomen en Struiken)</td>
<td align="left">Kristine Vander Mijnsbrugge</td>
<td align="left">luc_vanhercke</td>
</tr>
<tr class="even">
<td align="right">73</td>
<td align="left">ABS-VB2011</td>
<td align="left">Vlaams-Brabant 2011 Bijkomende opnames (Inventarisatie Autochtone Bomen en Struiken)</td>
<td align="left">Kristine Vander Mijnsbrugge</td>
<td align="left">luc_vanhercke</td>
</tr>
<tr class="odd">
<td align="right">74</td>
<td align="left">ABS-LEU2000</td>
<td align="left">Leuven 2000 (Inventarisatie Autochtone Bomen en Struiken)</td>
<td align="left">Kristine Vander Mijnsbrugge</td>
<td align="left">luc_vanhercke</td>
</tr>
<tr class="even">
<td align="right">75</td>
<td align="left">Meerdaalwoud - Militair domein - open vegetatie</td>
<td align="left">Een vegetatiestudie van het militair domein in Meerdaalwoud - thesis Larissa Luyten - KULeuven</td>
<td align="left">Inbo</td>
<td align="left">els_debie</td>
</tr>
<tr class="odd">
<td align="right">76</td>
<td align="left">Aardgat - rasterkartering</td>
<td align="left">Hydrologische en bodemkundige standplaatskarakteristieken van de vegetatie in het NR 'Het Aardgat' in Tienen. Thesis KULeuven. rasterkartering adhv vaste soortenlijst</td>
<td align="left">INBO</td>
<td align="left">els_debie</td>
</tr>
<tr class="even">
<td align="right">77</td>
<td align="left">Turnhoutse Vennen- ecologische studie</td>
<td align="left">vengerichte landschapsanalyse en de abiotische en vegetatiekundige historiek van een aantal vennen. thesis UGent, promotor Maurice Hoffman</td>
<td align="left">UGent</td>
<td align="left">els_debie</td>
</tr>
<tr class="odd">
<td align="right">78</td>
<td align="left">Meerdaalwoud - Militair domein - Bos vegetatie</td>
<td align="left">Een vegetatiestudie van het militair domein in Meerdaalwoud - thesis Larissa Luyten – KULeuven</td>
<td align="left">INBO</td>
<td align="left">els_debie</td>
</tr>
<tr class="even">
<td align="right">79</td>
<td align="left">Bourgoye-Ossemeersen NR vegetatiekaart</td>
<td align="left">Butaye J, De Becker P, Malfait J-P (1995) Verklarende tekst bij de vegetatiekaart van het natuurreservaat de Bourgoyen-Ossemeersen. Rapport van het Instituut voor Natuurbehoud.</td>
<td align="left">INBO</td>
<td align="left">els_debie</td>
</tr>
<tr class="odd">
<td align="right">80</td>
<td align="left">Duling en Hageven - 2001</td>
<td align="left">Opnames gemaakt door Else Demeulenaere en Filiep T'Jollyn in 2001. Uit veldboekje</td>
<td align="left">INBO</td>
<td align="left">els_debie</td>
</tr>
<tr class="even">
<td align="right">81</td>
<td align="left">Het Goorken-Lokkerse Dammen-ThesisUIA_1982</td>
<td align="left">Floristisch, fytosociologisch en ecologisch onderzoek van het goorken en de lokkerse dammen te arendonk. UIA Thesis. Mahieu R, De Baere D (1982)</td>
<td align="left">INBO</td>
<td align="left">els_debie</td>
</tr>
<tr class="odd">
<td align="right">82</td>
<td align="left">Demerbroeken2000</td>
<td align="left">Gedetailleerde vegetatiekartering van het studiegebied de Demerbroeken - Ecolas - 2000 iov Afdeling Water (buitendienst A'pen). auteurs Deconinck M, Vervoort W, Lambrechts D en Van Loock W</td>
<td align="left">INBO</td>
<td align="left">els_debie</td>
</tr>
<tr class="even">
<td align="right">83</td>
<td align="left">Breedven en Ven onder de Berg</td>
<td align="left">Vegetatiekartering van het Breedven en Ven onder de Berg - een ecohydrologische analyse. Envico (2000)-</td>
<td align="left">INBO</td>
<td align="left">els_debie</td>
</tr>
<tr class="odd">
<td align="right">84</td>
<td align="left">OudeKreken_Assenede</td>
<td align="left">Coudenys H (1985) fytosociologische studie van enkele oude kreken te Assenede (Oost-Vlaanderen) - thesis RUGent</td>
<td align="left">UGent</td>
<td align="left">els_debie</td>
</tr>
<tr class="even">
<td align="right">85</td>
<td align="left">Hannecart_1993</td>
<td align="left">Dumon I (1993) Vegetatiekundige studie en kartering van de epifyten van het staatsnatuurreservaat 'Hannecart' (Oostduinkerke, West-Vlaanderen, België) - theiss UGent</td>
<td align="left">INBO</td>
<td align="left">els_debie</td>
</tr>
<tr class="odd">
<td align="right">86</td>
<td align="left">TerYde_1996</td>
<td align="left">Baeté et al (1997) Ontwerpbeheersplan voor ht staatsnatuurreservaat Hannecartbos, gekaderd in een gebiedsvisie voor het duinencomplex Ter Yde. UGent iov Afd Natuur</td>
<td align="left">UGent</td>
<td align="left">els_debie</td>
</tr>
<tr class="even">
<td align="right">87</td>
<td align="left">Rietlanden_OostvlaamseKreken_1975</td>
<td align="left">De Raeve Frank (1975) Vegetatiekundige studie van de rietlanden van enkele Oostvlaamse kreken. thesis RUGent</td>
<td align="left">UGent</td>
<td align="left">els_debie</td>
</tr>
<tr class="odd">
<td align="right">88</td>
<td align="left">Moerasvegetatie_KleineNete</td>
<td align="left">Peymen J (1990) Typologie van moerasvegetatie in een kempisch stroombekken - Kleine Nete. Thesis UA</td>
<td align="left">UA</td>
<td align="left">els_debie</td>
</tr>
<tr class="even">
<td align="right">89</td>
<td align="left">LageMoeren_Meetkerke</td>
<td align="left">De Block W (1981) Randvoorwaarden voor het behoud van waardevolle oecotopen in het natuurgebied &quot;De Lage Moere&quot; te Meetkerke. RUGent iov Ruilverkavelingscomité Houtave</td>
<td align="left">INBO</td>
<td align="left">els_debie</td>
</tr>
<tr class="odd">
<td align="right">90</td>
<td align="left">DenDiel_1983</td>
<td align="left">Hermans H en Van der Auwera MC (1984) Floristisch, Ekologisch en Fytosociologisch onderzoek van den Diel te Mol (Antwerpen) Thesis UA</td>
<td align="left">UIA</td>
<td align="left">els_debie</td>
</tr>
<tr class="even">
<td align="right">98</td>
<td align="left">MILKLIM_W&amp;Z_bermen_IJzerdistrict</td>
<td align="left">ecologische opvolging van de bermvegetatie langs waterwegen in het IJzerdistrict</td>
<td align="left">MILKLIM</td>
<td align="left">andy_vankerckvoorde</td>
</tr>
<tr class="odd">
<td align="right">100</td>
<td align="left">Zwingraslanden 2014</td>
<td align="left">Vegetatieopnames i.f.v. project remote sensing van Zwingraslanden (n.a.v. BelAir). In samenwerking met KULeuven.</td>
<td align="left">Jeroen Vanden Borre</td>
<td align="left">jeroen_vandenborre</td>
</tr>
<tr class="even">
<td align="right">101</td>
<td align="left">Mechels Broek_ 1976</td>
<td align="left">Bauwens D (1976) Een veldbiologische studie van het Mechels Broek (Mechelen, Bonheiden, Muizen) ten behoeve van inrichting en beheer. - Thesis UAntwerpen</td>
<td align="left">UAntwerpen</td>
<td align="left">els_debie</td>
</tr>
<tr class="odd">
<td align="right">102</td>
<td align="left">KalmthoutseHeide_1978</td>
<td align="left">De Blust G. (1978) Vegetatiekartering van het Staatsnatuurreservaat 'De Kalmthoutse Heide'. Studie uitgevoerd door UIA i.o.v. Ministerie van Landbouw, bestuur van Waters en Bossen</td>
<td align="left">INBO</td>
<td align="left">els_debie</td>
</tr>
<tr class="even">
<td align="right">103</td>
<td align="left">Drongengoed_1983</td>
<td align="left">Lenoir L (1984)Vegetatiekundige studie van het Drongengoed (Oost-Vlaanderen) - RUG, Fakulteit der Wetendschappen,</td>
<td align="left"></td>
<td align="left"></td>
</tr>
<tr class="odd">
<td align="right">Promot</td>
<td align="left">or : Prof. Dr. P. Van Der Veken</td>
<td align="left">UGent els_debie</td>
<td align="left"></td>
<td align="left"></td>
</tr>
<tr class="even">
<td align="right">104</td>
<td align="left">GulkePutten_1978</td>
<td align="left">Viane H (1979) Vegetatiekundige studie van enkele percelen schraal grasland in het Gulke Putten reservaat te Wingene. RUG, Faculteit der Wetenschappen, Promotor : Prof.Dr.P. Van Der Veken</td>
<td align="left">UGent</td>
<td align="left">els_debie</td>
</tr>
<tr class="odd">
<td align="right">105</td>
<td align="left">SoortbescherminsplanGentiaanblauwtje</td>
<td align="left">Vanreusel W, Maes D &amp; Van Dyck H (2000) Soortbeschermingsplan Gentiaanblauwtje - Rapport van de UA iov Afdeling Natuur</td>
<td align="left">ANB</td>
<td align="left">els_debie</td>
</tr>
<tr class="even">
<td align="right">106</td>
<td align="left">DeBlankaert-1976</td>
<td align="left">Gryseels M (1977) Vegetatiekundige studie van de oeverlanden van de Blankaart (Woumen, Prov. West-Vlaanderen) RUG, Faculteit der Wetenschappen, Promotor : Prof. Dr. P. Van Der Veken</td>
<td align="left">UGent</td>
<td align="left">els_debie</td>
</tr>
<tr class="odd">
<td align="right">107</td>
<td align="left">MILKLIM_W&amp;Z_NTMB_Moervaart</td>
<td align="left">plots langs transecten</td>
<td align="left">Sophie Vermeersch</td>
<td align="left">maud_raman</td>
</tr>
<tr class="even">
<td align="right">108</td>
<td align="left">ToeristischeLeie_1988</td>
<td align="left">Minnaert et al (1988) Structuurschets Recreatie en Toerisme - Landschapspark Toeristische Leie. Gewestelijke Ontwikkelingsmaatschappij Oost-Vlaanderen, Gent D/1988/2688/7</td>
<td align="left">GOMO</td>
<td align="left">els_debie</td>
</tr>
<tr class="odd">
<td align="right">109</td>
<td align="left">ABS-VL 98-1 HB</td>
<td align="left">Hechtel-Bree 1998 (Inventarisatie Autochtone Bomen en Struiken)</td>
<td align="left">Kristine Vander Mijnsbrugge</td>
<td align="left">luc_vanhercke</td>
</tr>
<tr class="even">
<td align="right">110</td>
<td align="left">ABS-VL 98-1 WH</td>
<td align="left">West-Vlaams Heuvelland 1998 (Inventarisatie Autochtone Bomen en Struiken)</td>
<td align="left">Kristine Vander Mijnsbrugge</td>
<td align="left">luc_vanhercke</td>
</tr>
<tr class="odd">
<td align="right">111</td>
<td align="left">ABS-VlA 99-3</td>
<td align="left">Vlaamse Ardennen 1999 (Inventarisatie Autochtone Bomen en Struiken)</td>
<td align="left">Kristine Vander Mijnsbrugge</td>
<td align="left">luc_vanhercke</td>
</tr>
<tr class="even">
<td align="right">112</td>
<td align="left">ABS-WVl 99-2</td>
<td align="left">West-Vlaams Heuvelland 1999 (Inventarisatie Autochtone Bomen en Struiken)</td>
<td align="left">Kristine Vander Mijnsbrugge</td>
<td align="left">luc_vanhercke</td>
</tr>
<tr class="odd">
<td align="right">113</td>
<td align="left">ABS-LIM2010</td>
<td align="left">Limburg 2010 Bijkomende opnames (Inventarisatie Autochtone Bomen en Struiken)</td>
<td align="left">Kristine Vander Mijnsbrugge</td>
<td align="left">luc_vanhercke</td>
</tr>
<tr class="even">
<td align="right">114</td>
<td align="left">ABS-LIM2011</td>
<td align="left">Limburg 2011 Bijkomende opnames (Inventarisatie Autochtone Bomen en Struiken)</td>
<td align="left">Kristine Vander Mijnsbrugge</td>
<td align="left">luc_vanhercke</td>
</tr>
<tr class="odd">
<td align="right">115</td>
<td align="left">DeDonken_1980</td>
<td align="left">Geebelen J (1980) Floristische en fytosociologische studie van het natuurgebied &quot;De Donken&quot; te Turnhout. KULeuven, Promotor: Prof Dr Petit E</td>
<td align="left">KULeuven</td>
<td align="left">els_debie</td>
</tr>
<tr class="even">
<td align="right">116</td>
<td align="left">DeZegge_1981</td>
<td align="left">Van Speybroek et al (1981) Fytosociologische Schets van het Natuurreservaat de Zegge (Geel, Belgium)</td>
<td align="left">NA</td>
<td align="left">els_debie</td>
</tr>
<tr class="odd">
<td align="right">118</td>
<td align="left">Habistat</td>
<td align="left">Habistat opnames van 2006 tot 2010 in Kalmthout en DijleVallei. Methode BioHab. Overgebracht uit de oude databank (cslocal)</td>
<td align="left">INBO</td>
<td align="left">luc_vanhercke</td>
</tr>
<tr class="even">
<td align="right">119</td>
<td align="left">VandenBerghen_1953</td>
<td align="left">Aperçu sur la végétation de la région de Lebekke. Vanden Berghen Cyriel</td>
<td align="left">Cyriel Vanden Berghen</td>
<td align="left">els_debie</td>
</tr>
<tr class="odd">
<td align="right">120</td>
<td align="left">DistrictMaritime_Lambinon_1956</td>
<td align="left">Aperçu sur les groupements végétaux du district maritime belge enter La Panne et Coxyde - Lambinon, 1956</td>
<td align="left">Société Royale de Botanique de Belgique</td>
<td align="left">els_debie</td>
</tr>
<tr class="even">
<td align="right">121</td>
<td align="left">Duvigneaud1947_PannesDunesLittorales</td>
<td align="left">Remarques sur la végétation des pannes dans les dunes littorales entre La Panne et Dunkerque. Paul Duvigneaud (1947)</td>
<td align="left">NA</td>
<td align="left">els_debie</td>
</tr>
<tr class="odd">
<td align="right">122</td>
<td align="left">VandenBerghe1951_LandesTourbeuses</td>
<td align="left">Landes tourbeuses et tourbières bombées a Sphaignes de Belgique (Ericeto-sphagnetalia Schwickerath 1940) Vanden Berghe C (1951)</td>
<td align="left">NA</td>
<td align="left">els_debie</td>
</tr>
<tr class="even">
<td align="right">123</td>
<td align="left">VandenBerghe1952_Bas-marais</td>
<td align="left">Contribution a l'etude des bas-marais de Belgique. Vanden Berghe C (1952)</td>
<td align="left">NA</td>
<td align="left">els_debie</td>
</tr>
<tr class="odd">
<td align="right">124</td>
<td align="left">LatemseMeersen_1982</td>
<td align="left">Delphine De Hemptinne (1983) Landschapsstudie van de Latemse Meersen. Inventarisatie, evaluatie en beheer. Thesis RUGent</td>
<td align="left">RUGEnt</td>
<td align="left">els_debie</td>
</tr>
<tr class="even">
<td align="right">125</td>
<td align="left">Buitengoor_1990</td>
<td align="left">Delbaere Ben (1990) Studie naar de invloed van de topografie op de watersamenstelling, de bodemsamenstelling en de soortensamenstelling in het Buitengoor (Mol/België) - thesis Licenciaat UIA</td>
<td align="left">UIA</td>
<td align="left">els_debie</td>
</tr>
<tr class="odd">
<td align="right">126</td>
<td align="left">Heinemann_1956</td>
<td align="left">Les landes a calluna du district picardo-brabancon de belgique. P. Heinemann</td>
<td align="left">NA</td>
<td align="left">els_debie</td>
</tr>
<tr class="even">
<td align="right">127</td>
<td align="left">DeMaten_1985</td>
<td align="left">Stans L (1985). Vergelijkende fytosociologische studie van de Maten, in relatie met het beheer. KUL, Faculteit der wetenschappen, Promotor : Dr. N.De Maesschalk-Podoor</td>
<td align="left">KULeuven</td>
<td align="left">els_debie</td>
</tr>
<tr class="odd">
<td align="right">128</td>
<td align="left">N2000meetnet_Grasland</td>
<td align="left">geneste vegetatie - en structuuropnames ter beoordeling en opvolging van de regionale SVI van de Natura 2000 grasland en moerastypes</td>
<td align="left">OG Biotoopmonitoring</td>
<td align="left">patrik_oosterlynck</td>
</tr>
<tr class="even">
<td align="right">129</td>
<td align="left">Schorren_VanLangendonck1933</td>
<td align="left">Van Langendonck (1933) La sociologie végétale des schorres du Zwyn et de Philippine. Bulletin de la Société Royale de Botanique de Belgique, t. LXV, fasc2, 1933</td>
<td align="left">H.J. van Langendonck</td>
<td align="left">els_debie</td>
</tr>
<tr class="odd">
<td align="right">130</td>
<td align="left">Vloethemveld_ZwaenepoelHermy1987</td>
<td align="left">Cicendia filiformis en andere nanocyperion-soorten in het Vloethemveld: een pleidooi voor biotoopbescherming en beheer. Arnoud Zwaenepoel en Martin Herm</td>
<td align="left">Zwaenepoel en Hermy</td>
<td align="left">els_debie</td>
</tr>
<tr class="even">
<td align="right">131</td>
<td align="left">VestigingsgrachtenDamme_DanneelsHermy1986</td>
<td align="left">Verlandingsgemeenschappen van de vestigingsgrachten van Damme. Pol Daneels en Martin Hermy.</td>
<td align="left">NA</td>
<td align="left">els_debie</td>
</tr>
<tr class="odd">
<td align="right">132</td>
<td align="left">sGravendel_PaelinckxSoetens1983</td>
<td align="left">Het natuurgebied 's Gravendel (Retie). 1 - Fytosociologische beschrijving in relatie tot vochtigheid en bodem. Desiré Paelinckx en Ria Soetens</td>
<td align="left">Desiré Paelinckx</td>
<td align="left">els_debie</td>
</tr>
<tr class="even">
<td align="right">133</td>
<td align="left">Leiemeersen_Gryseels1981</td>
<td align="left">Derelict marsh and meadow vegetation of the Leiemeersen at Oostkamp. Machteld Gryseels en Martin Hermy.</td>
<td align="left">Machteld Gryseels</td>
<td align="left">els_debie</td>
</tr>
<tr class="odd">
<td align="right">134</td>
<td align="left">GulkePutten_Stieperaere1983</td>
<td align="left">Viable seeds in the soils of some parcels of reclaimed and unreclamed heath in the Flemisch district (Northern Belgium). H. Stieperaer en C. Timmerman</td>
<td align="left">Herman Stieperaere</td>
<td align="left">els_debie</td>
</tr>
<tr class="even">
<td align="right">135</td>
<td align="left">ZwarteBeek_MiekeDeWilde1997</td>
<td align="left">Ecohydrologische studie van een aantal grondwaterafhankelijke vegetaties in de vallei van de Zwarte Beek. Thesis KUL</td>
<td align="left">Mieke De Wilde</td>
<td align="left">els_debie</td>
</tr>
<tr class="odd">
<td align="right">136</td>
<td align="left">KalmthoutseHeide_1998</td>
<td align="left">Brijs R. De invloed van recente branden op droge en vochtige heidevegetaties op de Kalmthoutse Heide met specifieke aandacht voor Molinia caerulea. Thesis UGent</td>
<td align="left">UGent</td>
<td align="left">els_debie</td>
</tr>
<tr class="even">
<td align="right">137</td>
<td align="left">Kindernouw-Visbeek1994</td>
<td align="left">Kris Rombouts - Vegetatiekundige en ecologische studie van de Kindernouw-Visbeekvallei. Thesis UGent. Promotor Van der Veken</td>
<td align="left">UGent</td>
<td align="left">els_debie</td>
</tr>
<tr class="odd">
<td align="right">138</td>
<td align="left">Zandwinningsputten_1998</td>
<td align="left">Veerle Beyst. Natuur- en landschapsontwikkeling in Zandwinningsputten. UA thesis. Promotor Dirk Boeye</td>
<td align="left">UA</td>
<td align="left">els_debie</td>
</tr>
<tr class="even">
<td align="right">139</td>
<td align="left">Monitoring Ratio</td>
<td align="left">opnames van PQ's in Grensmaasregio t.b.v. ecologische monitoring i.k.v. Ratio-overleg</td>
<td align="left">MILKLIM</td>
<td align="left">jan_wouters</td>
</tr>
<tr class="odd">
<td align="right">140</td>
<td align="left">Zwingraslanden2015</td>
<td align="left">Vegetatieopnames i.f.v. project remote sensing van graslanden (n.a.v. BELAIR). In samenwerking met KULeuven.</td>
<td align="left">Jeroen Vanden Borre</td>
<td align="left">jeroen_vandenborre</td>
</tr>
<tr class="even">
<td align="right">141</td>
<td align="left">LageMoereMeetkerke2015</td>
<td align="left">Vegetatieopnames i.f.v. project remote sensing van graslanden (n.a.v. BELAIR). In samenwerking met KULeuven.</td>
<td align="left">Jeroen Vanden Borre</td>
<td align="left">jeroen_vandenborre</td>
</tr>
<tr class="odd">
<td align="right">142</td>
<td align="left">KalmthoutseHeide2015</td>
<td align="left">Vegetatieopnames i.f.v. project remote sensing van heidegebieden.</td>
<td align="left">Jeroen Vanden Borre</td>
<td align="left">jeroen_vandenborre</td>
</tr>
<tr class="even">
<td align="right">143</td>
<td align="left">AverbodeBosHeide2015</td>
<td align="left">Vegetatieopnamen i.f.v. project remote sensing van heidegebieden</td>
<td align="left">Jeroen Vanden Borre</td>
<td align="left">jeroen_vandenborre</td>
</tr>
<tr class="odd">
<td align="right">146</td>
<td align="left">MILKLIM_W&amp;Z_bermen_Leopoldkanaal</td>
<td align="left">Ecologische opvolging bermvegetaties Leopoldkanaal</td>
<td align="left">MILKLIM</td>
<td align="left">andy_vankerckvoorde</td>
</tr>
<tr class="even">
<td align="right">148</td>
<td align="left">MILKLIM_W&amp;Z_bermen_dataW&amp;Z</td>
<td align="left">opnames in bermen door derden langs W&amp;Z-waterwegen</td>
<td align="left">W&amp;Z</td>
<td align="left">andy_vankerckvoorde</td>
</tr>
<tr class="odd">
<td align="right">152</td>
<td align="left">Molsbroek_1971_Watervegetatie</td>
<td align="left">H_Quitelier. Fytosociologische stude van een moerasreservaat 'Het Molsbroek' in Lokeren. RUG, Faculteit der Wetenschappen, Prom. : Prof. Dr. P. Van Der Veken</td>
<td align="left">UGent</td>
<td align="left">els_debie</td>
</tr>
<tr class="even">
<td align="right">153</td>
<td align="left">Molsbroek_1971_terrestrische vegetatie</td>
<td align="left">H_Quintelier. Fytosociologische studie van een moerasreservaat 'Het Molsbroek' in Lokeren. RUG, Faculteit der Wetenschappen, Prom. : Prof. Dr. P. Van Der Veken</td>
<td align="left">UGent</td>
<td align="left">els_debie</td>
</tr>
<tr class="odd">
<td align="right">160</td>
<td align="left">MILKLIM_W&amp;Z_bermen_middenberm_LEO_AFL</td>
<td align="left">Ecologische opvolging van de middenberm tussen het Leopoldkanaal en het Afleidingskanaal van de Leie</td>
<td align="left">NA</td>
<td align="left">andy_vankerckvoorde</td>
</tr>
<tr class="even">
<td align="right">161</td>
<td align="left">DeMaten_1978</td>
<td align="left">Delwiche Julienne. Floristische en fytosociologische studie van het natuurreservaat &quot;De Maten&quot; (Genk-Diepenbeek).KUL, Fakulteit der Wetenschappen, Afdeling Plantkunde, Promotor : Prof.Dr.E. Petit</td>
<td align="left">KULeuven</td>
<td align="left">els_debie</td>
</tr>
<tr class="odd">
<td align="right">162</td>
<td align="left">'tVen_1977</td>
<td align="left">Dewals Mia. Bijdrage tot de floristische en fytosociologische studie van &quot; 't Ven &quot; te Rijmenam. KUL, Fakulteit der Wetenschappen, Leerstoel voor Morfologie, Systematiek en Oecologie van de planten, Prof. Dr.E.Petit</td>
<td align="left">KULeuven</td>
<td align="left">els_debie</td>
</tr>
<tr class="even">
<td align="right">163</td>
<td align="left">Tikkebroeken_1976</td>
<td align="left">Marynissen Rita. Floristische en Fytosociologische studie van het reservaat &quot;De Tikkebroeken&quot; (te Kasterlee &amp; Oud-Turnhout). KUL, Fakulteit der Wetenschappen, Prom. : Prof. Dr. E.Petit</td>
<td align="left">KULeuven</td>
<td align="left">els_debie</td>
</tr>
<tr class="odd">
<td align="right">164</td>
<td align="left">Dorpsbeemden_1986</td>
<td align="left">Froyen Lutgart. Gradientanalyse van een soortenrijk hooiland. UIA, Fakulteit Wetenschappen, Sektie Biologie, Richting Plantkunde, Promotor : Prof. Dr.R.F. V</td>
<td align="left">UIA</td>
<td align="left">els_debie</td>
</tr>
<tr class="even">
<td align="right">165</td>
<td align="left">DeFonteintjes_Vanhecke</td>
<td align="left">Vanhecke Leo (1994). De wisselende aanwezigheid van Potamogeton coloratus in het natuurreservaat De Fonteintjes (W.-VL)</td>
<td align="left">Leo Vanhecke</td>
<td align="left">els_debie</td>
</tr>
<tr class="odd">
<td align="right">166</td>
<td align="left">Carexpunctata_Leten</td>
<td align="left">Leten et al (1994) Carex punctata Gaudin, nieuw voor België, in het Panneweel (St.-Gillis-Waas) en in het Hof ter Saksen (Beveren)</td>
<td align="left">INBO</td>
<td align="left">els_debie</td>
</tr>
<tr class="even">
<td align="right">167</td>
<td align="left">Smeetshof_natuurinrichitng_2015PQ</td>
<td align="left">Natuurinrichtingsproject Smeetshof. Onderzoek door INBO</td>
<td align="left">INBO</td>
<td align="left">els_debie</td>
</tr>
<tr class="odd">
<td align="right">168</td>
<td align="left">Draadrus_1982</td>
<td align="left">Lejeune M &amp; Burny J. (1982) Groeiplaats van de draadrus in de vallei van de Zwarte beek te Koersel (Limburg, België)</td>
<td align="left">NA</td>
<td align="left">els_debie</td>
</tr>
<tr class="even">
<td align="right">169</td>
<td align="left">Botrychium_1975</td>
<td align="left">Stieperaere H (1975) Een recente groeiplaats van Botrychium lunaria in het Vlaams District te Wingene (prov. West-Vlaanderen)</td>
<td align="left">NA</td>
<td align="left">els_debie</td>
</tr>
<tr class="odd">
<td align="right">170</td>
<td align="left">GageaLutea_1980</td>
<td align="left">Hermy M (1980) Een belangrijke nieuwe vindplaats van Gagea lutea (L.) Ker-Gawl. langs de Hertsbergebeek te Oostkamp (Prov West-Vl).</td>
<td align="left">NA</td>
<td align="left">els_debie</td>
</tr>
<tr class="even">
<td align="right">171</td>
<td align="left">Luithagen_1980</td>
<td align="left">Verlinden A (1980) De plantengroei van het opgespoten terrein 'Luithagen' te Antwerpen.</td>
<td align="left">NA</td>
<td align="left">els_debie</td>
</tr>
<tr class="odd">
<td align="right">172</td>
<td align="left">OudeLanden_1979</td>
<td align="left">Verlinden A, Leys G en Slembrouck J (1979) Groeiplaatsen van Ophioglossum vulgatum en Orphys apifera bij Antwerpen</td>
<td align="left">NA</td>
<td align="left">els_debie</td>
</tr>
<tr class="even">
<td align="right">173</td>
<td align="left">Buitengoor_1979</td>
<td align="left">De Langhe, Westhoff en D'Hose (1979) De plantengroei van het Buitengoor te Mol (Antwerpen)</td>
<td align="left">NA</td>
<td align="left">els_debie</td>
</tr>
<tr class="odd">
<td align="right">174</td>
<td align="left">Kraenepoel_1956</td>
<td align="left">Daels L (1956) Plantenaardrijkskundige studie van een gebied gelegen rond de Kraenepoel.</td>
<td align="left">NA</td>
<td align="left">els_debie</td>
</tr>
<tr class="even">
<td align="right">175</td>
<td align="left">WestendseHeide_1974</td>
<td align="left">Vanhecke L (1974) Een bijna vergeten en verdwenen site: de Westendse heide.</td>
<td align="left">NA</td>
<td align="left">els_debie</td>
</tr>
<tr class="odd">
<td align="right">176</td>
<td align="left">Beverlo-2012</td>
<td align="left">Opnames gemaakt in het Kamp van Beverlo Zuid</td>
<td align="left">INBO</td>
<td align="left">els_debie</td>
</tr>
<tr class="even">
<td align="right">177</td>
<td align="left">Demer-Dijle-1996</td>
<td align="left">Ecologisch impulsgebied Demer en Dijle: inventarisatie van de natuurwaarden in de Demervallei tussen Werchter en Diest. September 1997. Onderzoek uitgevoerd aan de KULeuven Lab voor Bos, Natuur en Landschap in opdracht van AMINAL afd. Natuur (Vl Brab)</td>
<td align="left">ANB</td>
<td align="left">els_debie</td>
</tr>
<tr class="odd">
<td align="right">178</td>
<td align="left">Platanthera_chlorantha</td>
<td align="left">Tavernier et al. (1980)Platanthera chlorantha (cust.) Reichenb. binnn de Brusselse agglomeratie</td>
<td align="left">NA</td>
<td align="left">els_debie</td>
</tr>
<tr class="even">
<td align="right">179</td>
<td align="left">Haven Antwerpen 2010</td>
<td align="left">Opnames van Ralf Gyselings gemaakt in het havengebied (Biohab en Classic) overgenomen uit de biohabSigma databank.</td>
<td align="left">NA</td>
<td align="left">luc_vanhercke</td>
</tr>
<tr class="odd">
<td align="right">180</td>
<td align="left">Compensatie_Achterhaven_Zeebrugge</td>
<td align="left">NA</td>
<td align="left">EVINBO</td>
<td align="left">els_debie</td>
</tr>
<tr class="even">
<td align="right">181</td>
<td align="left">Duinstreek Herrier 1989</td>
<td align="left">uit Herrier (1989) Vegetatiekundige bijdrage tot de landschapsecologie van de duinstreek van het Zwin. UGent – faculteit van de landbouwwetenschappen, promotor ir. H. Beeckman.</td>
<td align="left">UGent</td>
<td align="left">els_debie</td>
</tr>
<tr class="odd">
<td align="right">182</td>
<td align="left">Oostendse Polders 1984</td>
<td align="left">Opnames van Dumollin, J. (1985). Vegetatiekundig onderzoek van de vochtige gebieden in de Oostendse polders. MSc Thesis. Rijksuniversiteit Gent. Faculteit Wetenschappen: Gent. 102 pp.</td>
<td align="left">UGent</td>
<td align="left">els_debie</td>
</tr>
<tr class="even">
<td align="right">183</td>
<td align="left">DeBlankaart-1985-Vegetatie</td>
<td align="left">Blankaart Machteld Gryseels - De opnames van het luik Vegetatie-onderzoek.</td>
<td align="left">RUG</td>
<td align="left">els_debie</td>
</tr>
<tr class="odd">
<td align="right">184</td>
<td align="left">DeBlankaart-1985-Beheer</td>
<td align="left">Blankaart Machteld Gryseels - De opnames van het luik Experimenteel Onderzoek Beheer</td>
<td align="left">RUG</td>
<td align="left">els_debie</td>
</tr>
<tr class="even">
<td align="right">186</td>
<td align="left">MILKLIM_Denderleeuw</td>
<td align="left">PQ's eilandje Denderleeuw</td>
<td align="left">Maud Raman</td>
<td align="left">maud_raman</td>
</tr>
<tr class="odd">
<td align="right">187</td>
<td align="left">HT3260</td>
<td align="left">Inventarisatie van waterlopen in kader van de LSVI - Habitattype 3260</td>
<td align="left">INBO</td>
<td align="left">els_debie</td>
</tr>
<tr class="even">
<td align="right">188</td>
<td align="left">W&amp;Z_NTMB_afd.Zeekanaal</td>
<td align="left">opnames van NTMB-oevers langs het Kanaal Brussel-Schelde (Grimbergen en Wintam) en het Kanaal Charleroi–Brussel (Lot)</td>
<td align="left">Andy Van Kerckvoorde</td>
<td align="left">andy_vankerckvoorde</td>
</tr>
<tr class="odd">
<td align="right">189</td>
<td align="left">Bodeux_1949</td>
<td align="left">Vegetatieopnames Heide Limburg 1948-1949</td>
<td align="left">NA</td>
<td align="left">els_debie</td>
</tr>
<tr class="even">
<td align="right">190</td>
<td align="left">HetMoer_1981</td>
<td align="left">Ronny Segers (1981) Natuurgebied &quot;Het Moer&quot; te Bornem : een oecologische inventarisatie. Licentiaatsverhandeling RUG</td>
<td align="left">RUG</td>
<td align="left">els_debie</td>
</tr>
<tr class="odd">
<td align="right">191</td>
<td align="left">Zeeschelde_1992</td>
<td align="left">Vegetatieopnames van de zeeschelde in 1992 door Maurice Hoffmann</td>
<td align="left">NA</td>
<td align="left">els_debie</td>
</tr>
<tr class="even">
<td align="right">192</td>
<td align="left">N2000meetnet_Moerassen</td>
<td align="left">geneste vegetatie - en structuuropnames ter beoordeling en opvolging van de regionale SVI van de Natura 2000 moerastypes</td>
<td align="left">OG Biotoopdiversiteit</td>
<td align="left">patrik_oosterlynck</td>
</tr>
<tr class="odd">
<td align="right">193</td>
<td align="left">HT31xx_Plassen</td>
<td align="left">Inventarisatie van habitatwaardige plassen</td>
<td align="left">INBO</td>
<td align="left">els_debie</td>
</tr>
<tr class="even">
<td align="right">194</td>
<td align="left">TESTsurvey</td>
<td align="left">deze survey is opgemaakt voor het testen van de soortenlijst voor vincent S</td>
<td align="left">INBO</td>
<td align="left">els_debie</td>
</tr>
<tr class="odd">
<td align="right">195</td>
<td align="left">Cochleariadanica_bermhalofyt</td>
<td align="left">Onderzoek naar de bermhalofyt Cochlearia danica L. langs verkeerswegen in het Vlaamse binnenland.</td>
<td align="left">Laboratorium Plantkunde, RUGent</td>
<td align="left">els_debie</td>
</tr>
<tr class="even">
<td align="right">196</td>
<td align="left">HT31xx_LSVI_StilstaandeWateren</td>
<td align="left">Opnames gemaakt in kader van de LSVI bepalingen van plassen.</td>
<td align="left">INBO</td>
<td align="left">els_debie</td>
</tr>
<tr class="odd">
<td align="right">197</td>
<td align="left">KalkgraslandenVlaanderen_2001</td>
<td align="left">Zijn kalkgraslanden nog aanwezig in Vlaanderen? Waar komen ze nog voor en wat zijn hun kenmerken? - Scriptie UGent</td>
<td align="left">Maud Raman</td>
<td align="left">maud_raman</td>
</tr>
<tr class="even">
<td align="right">198</td>
<td align="left">LosseOpnames_IndraJacobs_Londo</td>
<td align="left">Losse vegetatieopnames, gemaakt al dan niet tijdens veldwerk, met gebruik van de schaal van Londo</td>
<td align="left">Indra Jacobs</td>
<td align="left">els_debie</td>
</tr>
<tr class="odd">
<td align="right">199</td>
<td align="left">LosseOpnames_IndraJacobs_BraunBlanquet</td>
<td align="left">losse vegetatieopnames gemaakt door Indra Jacobs, met behulp van de schaal van Braun-Blanquet</td>
<td align="left">Indra Jacobs</td>
<td align="left">els_debie</td>
</tr>
<tr class="even">
<td align="right">200</td>
<td align="left">LosseOpnames_IndraJacobs_Tansley</td>
<td align="left">Vegetatieopnames gemaakt met de schaal van Tansley door Indra Jacobs</td>
<td align="left">Indra Jacobs</td>
<td align="left">els_debie</td>
</tr>
<tr class="odd">
<td align="right">201</td>
<td align="left">ESTUARIA_Zilte_graslanden</td>
<td align="left">NA</td>
<td align="left">Frank Van de Meutter</td>
<td align="left">maud_raman</td>
</tr>
<tr class="even">
<td align="right">202</td>
<td align="left">Aardbeivlinder_Drongengoed</td>
<td align="left">Monitoring van de aardbeivlinder in het Drongengoed</td>
<td align="left">INBO</td>
<td align="left">els_debie</td>
</tr>
<tr class="odd">
<td align="right">203</td>
<td align="left">MILKLIM_pilootheidebekalking Braun-Blanquet</td>
<td align="left">Opvolging van pilootexperimenten heidebekalking (opnameninvoer door terreinbeheerders), opnameschaal: Braun-Blanquet</td>
<td align="left">MILKLIM</td>
<td align="left">jan_wouters</td>
</tr>
<tr class="even">
<td align="right">204</td>
<td align="left">Kust_PQ</td>
<td align="left">NA</td>
<td align="left">INBO</td>
<td align="left">sam_provoost</td>
</tr>
<tr class="odd">
<td align="right">206</td>
<td align="left">N2000meetnet_Grasland_BHM</td>
<td align="left">geneste structuur- en vegetatieopnames ter beoordeling van de regionale SVI van de Natura 2000 graslandtypes gebruik makende van de beheermonitoringsschaal2017</td>
<td align="left">OG Biotoopmonitoring</td>
<td align="left">patrik_oosterlynck</td>
</tr>
<tr class="even">
<td align="right">207</td>
<td align="left">N2000meetnet_Moeras_BHM</td>
<td align="left">geneste vegetatie_ en structuurplots ter beoordeling en opvolging van de regionale SVI van de Natura 2000 moerastypes gebruik makende van de beheermonitoringsschaal 2017</td>
<td align="left">OG Biotoopmonitoring</td>
<td align="left">patrik_oosterlynck</td>
</tr>
<tr class="odd">
<td align="right">208</td>
<td align="left">LosseOpnames_RemarErens_Londo</td>
<td align="left">Losse opnames van Remar Erens mbv Londo-schaal</td>
<td align="left">Remar Erens</td>
<td align="left">patrik_oosterlynck</td>
</tr>
<tr class="even">
<td align="right">209</td>
<td align="left">SBO_FutureFloodplains_beheer</td>
<td align="left">Beheerexperiment uitgevoerd in de Dijlevallei en de vallei van de Zwarte Beek in het kader van het SBO project Future Floodplains</td>
<td align="left">MilKlim</td>
<td align="left">siege_vanballaert</td>
</tr>
<tr class="odd">
<td align="right">210</td>
<td align="left">SBO_FutureFloodplains_abiotiek</td>
<td align="left">&quot;HabNorm&quot; voor 6430_hf, rbbhf, rbbmc, rbbmr</td>
<td align="left">NA</td>
<td align="left">siege_vanballaert</td>
</tr>
<tr class="even">
<td align="right">211</td>
<td align="left">Leiemeersen_Deinze</td>
<td align="left">monitoren van percelen</td>
<td align="left">NA</td>
<td align="left">els_debie</td>
</tr>
<tr class="odd">
<td align="right">212</td>
<td align="left">Vyvey_1979_Torfbroek</td>
<td align="left">Vyvey Q., Stieperaere H. (1981). The rich-fen vegetation of the nature reserve 'Het Torfbroek' at Berg-Kampenhout (prov. of Brabant, Belgium). Bulletin de la Société Royale de Botanique de Belgique 114:106-124.</td>
<td align="left">INBO</td>
<td align="left">jan_wouters</td>
</tr>
<tr class="even">
<td align="right">214</td>
<td align="left">N2000meetnet_Duinen_BHM</td>
<td align="left">geneste vegetatie_ en structuurplots ter beoordeling en opvolging van de regionale SVI van de Natura 2000 moerastypes gebruik makende van de beheermonitoringsschaal 2017</td>
<td align="left">OG Biotoopmonitoring</td>
<td align="left">patrik_oosterlynck</td>
</tr>
<tr class="odd">
<td align="right">215</td>
<td align="left">MILKLIM_overstromingen_DYL1999</td>
<td align="left">~ survey MILKLIM_overstromingen. Gekoppelde opnames die in 2011 opnieuw zijn gemaakt, maar enkel voor deelgebied Dijlevallei</td>
<td align="left">Siege Van Ballaert</td>
<td align="left">siege_vanballaert</td>
</tr>
<tr class="even">
<td align="right">217</td>
<td align="left">MILKLIM_Overstromingen_DYL1999_</td>
<td align="left">~ survey MILKLIM_overstromingen. Gekoppelde opnames die in 2011 opnieuw zijn gemaakt, maar enkel voor deelgebied Dijlevallei</td>
<td align="left">Siege Van Ballaert</td>
<td align="left">siege_vanballaert</td>
</tr>
<tr class="odd">
<td align="right">218</td>
<td align="left">SBO_FutureFloodplains_overstromingen_DYL2019</td>
<td align="left">Derde reeks herhalingen van opnames in het kader van het overstromingsproject (1999-2011-2019). Doel: alternatief voor oorspronkelijk beheerexperiment</td>
<td align="left">Siege Van Ballaert</td>
<td align="left">siege_vanballaert</td>
</tr>
<tr class="even">
<td align="right">219</td>
<td align="left">Ijzermonding_Goetghebeur</td>
<td align="left">De vegetatie van de slikken en schorren langs de IJzermonding te Nieuwpoort van 1900 tot heden</td>
<td align="left">Paul Goetghebeur</td>
<td align="left">els_debie</td>
</tr>
<tr class="odd">
<td align="right">220</td>
<td align="left">NO_Maaibos_Londo</td>
<td align="left">Londo-opnames in kader van natuurontwikkeling in het Maaibos (Wachtebeke) door Greenspot</td>
<td align="left">Greenspot</td>
<td align="left">els_debie</td>
</tr>
<tr class="even">
<td align="right">221</td>
<td align="left">NO_Maaibos_Tansley</td>
<td align="left">Tansley-opnames in kader van natuurontwikkeling in het Maaibos (Wachtebeke) door Greenspot</td>
<td align="left">Greenspot</td>
<td align="left">els_debie</td>
</tr>
<tr class="odd">
<td align="right">222</td>
<td align="left">N2000meetnet_Heide_BHM</td>
<td align="left">NA</td>
<td align="left">INBO</td>
<td align="left">els_debie</td>
</tr>
</tbody>
</table>

only a part of the survey name is known?

    partsurveys <- inboveg_survey(con, 
                                  survey = "%MILKLIM%",
                                  collect = TRUE)

    partsurveys

<table>
<thead>
<tr class="header">
<th align="right">Id</th>
<th align="left">Name</th>
<th align="left">Description</th>
<th align="left">Owner</th>
<th align="left">creator</th>
</tr>
</thead>
<tbody>
<tr class="odd">
<td align="right">4</td>
<td align="left">MILKLIM_Alopecurion</td>
<td align="left">Standplaatsonderzoek graslanden behorende tot Alopecurion (6510hus en 6510hua)</td>
<td align="left">MILKLIM</td>
<td align="left">maud_raman</td>
</tr>
<tr class="even">
<td align="right">5</td>
<td align="left">MILKLIM_WZ_AalstTeralfene</td>
<td align="left">Opnamen van PQ's in regio Aalst en Teralfene (Dendervallei), in het kader van de waterpeilverlaging van de Dender. Binnen raamovereenkomst INBO-W&amp;Z.</td>
<td align="left">MILKLIM</td>
<td align="left">floris_vanderhaeghe</td>
</tr>
<tr class="odd">
<td align="right">6</td>
<td align="left">MILKLIM_Hei(schraal)herstel</td>
<td align="left">PQ's in kader van onderzoek naar de effectiviteit van natuurherstelmaatregelen in heide-achtige systemen</td>
<td align="left">MILKLIM</td>
<td align="left">floris_vanderhaeghe</td>
</tr>
<tr class="even">
<td align="right">7</td>
<td align="left">MILKLIM_Heide</td>
<td align="left">Standplaatsonderzoek heide</td>
<td align="left">MILKLIM</td>
<td align="left">jan_wouters</td>
</tr>
<tr class="odd">
<td align="right">8</td>
<td align="left">MILKLIM_W&amp;Z_Leiebermen_2010_2013</td>
<td align="left">Evaluatie maaibeheer Leiebermen gedurende de periode 2012_2013</td>
<td align="left">MILKLIM</td>
<td align="left">maud_raman</td>
</tr>
<tr class="even">
<td align="right">9</td>
<td align="left">MILKLIM_W&amp;Z_Geraardsbergen</td>
<td align="left">Vegetatieopnames in het kader van gebiedsverkenning naar aanleiding van geplande peilverlaging Dender</td>
<td align="left">MILKLIM</td>
<td align="left">luc_vanhercke</td>
</tr>
<tr class="odd">
<td align="right">10</td>
<td align="left">MILKLIM_Heischraal2012</td>
<td align="left">Vegetatieopnames in het kader van standplaatsonderzoek - heischrale graslanden</td>
<td align="left">MILKLIM</td>
<td align="left">cecile_herr</td>
</tr>
<tr class="even">
<td align="right">11</td>
<td align="left">MILKLIM_W&amp;Z_Varia</td>
<td align="left">Losse opnamen in het kader van kleine opdrachtjes voor W&amp;Z (adviezen, nota's, korte inventarisaties). Binnen raamovereenkomst INBO-W&amp;Z.</td>
<td align="left">MILKLIM</td>
<td align="left">floris_vanderhaeghe</td>
</tr>
<tr class="odd">
<td align="right">12</td>
<td align="left">MILKLIM_W&amp;Z_Bermen_AfleidingskanaalLeie</td>
<td align="left">Ecologische opvolging van bermvegetatie</td>
<td align="left">MILKLIM</td>
<td align="left">els_debie</td>
</tr>
<tr class="even">
<td align="right">14</td>
<td align="left">MILKLIM_W&amp;Z_OeversLeie</td>
<td align="left">Oeveropnamen langs de Leie ter evaluatie van oevermaatregelen genomen ikv Seine Schelde</td>
<td align="left">Maud Raman</td>
<td align="left">luc_vanhercke</td>
</tr>
<tr class="odd">
<td align="right">15</td>
<td align="left">MILKLIM_W&amp;Z_Leiemeanders</td>
<td align="left">Opvolging van PQ's langs meanders van de Leie in het kader van het Seine-Schelde-project. Valt onder raamovereenkomst INBO-W&amp;Z.</td>
<td align="left">MILKLIM</td>
<td align="left">floris_vanderhaeghe</td>
</tr>
<tr class="even">
<td align="right">16</td>
<td align="left">MILKLIM_Overstroming</td>
<td align="left">Vegetatieopnames gemaakt tijdens 2011 voor het ANB-project 'Verzamelen van basiskennis en ontwikkeling van een beoordelings- of afwegingskader voor de ecologische effectanalyse van overstromingen.</td>
<td align="left">Els De Bie</td>
<td align="left">els_debie</td>
</tr>
<tr class="odd">
<td align="right">20</td>
<td align="left">MILKLIM_OverstromingHoeleden</td>
<td align="left">Resultaten uit de thesis van Mikaël Maes - UGent - 2013</td>
<td align="left">INBO</td>
<td align="left">els_debie</td>
</tr>
<tr class="even">
<td align="right">23</td>
<td align="left">MILKLIM_BlauwVeldrusgrasland</td>
<td align="left">Standplaatsonderzoek veldrusgrasland, blauwgrasland en heischraal grasland</td>
<td align="left">MILKLIM</td>
<td align="left">jan_wouters</td>
</tr>
<tr class="odd">
<td align="right">29</td>
<td align="left">MILKLIM_W&amp;Z_Bermen_KanaalGentBrugge</td>
<td align="left">Opvolging van de bermvegetatie van het Kanaal Gent-Brugge; in opdracht van W&amp;Z</td>
<td align="left">MILKLIM</td>
<td align="left">els_debie</td>
</tr>
<tr class="even">
<td align="right">33</td>
<td align="left">MILKLIM_LevelII_BraunBlanquet</td>
<td align="left">Bosopnames in kader van het Level II bos-monitoringsproject</td>
<td align="left">INBO</td>
<td align="left">els_debie</td>
</tr>
<tr class="odd">
<td align="right">34</td>
<td align="left">MILKLIM_LevelII_Londo</td>
<td align="left">Bosopnames in kader van LevelII-monitoring</td>
<td align="left">INBO</td>
<td align="left">els_debie</td>
</tr>
<tr class="even">
<td align="right">35</td>
<td align="left">MILKLIM_W&amp;Z_vooroevers_KanaalGentBrugge</td>
<td align="left">Opvolging van de vegetatie in de vooroevers langs het Kanaal Gent-Brugge, in opdracht van W&amp;Z</td>
<td align="left">MILKLIM</td>
<td align="left">andy_vankerckvoorde</td>
</tr>
<tr class="odd">
<td align="right">43</td>
<td align="left">MILKLIM_pilootheidebekalking</td>
<td align="left">Opvolging van pilootexperimenten heidebekalking (opnameninvoer door terreinbeheerders)</td>
<td align="left">MILKLIM</td>
<td align="left">floris_vanderhaeghe</td>
</tr>
<tr class="even">
<td align="right">98</td>
<td align="left">MILKLIM_W&amp;Z_bermen_IJzerdistrict</td>
<td align="left">ecologische opvolging van de bermvegetatie langs waterwegen in het IJzerdistrict</td>
<td align="left">MILKLIM</td>
<td align="left">andy_vankerckvoorde</td>
</tr>
<tr class="odd">
<td align="right">107</td>
<td align="left">MILKLIM_W&amp;Z_NTMB_Moervaart</td>
<td align="left">plots langs transecten</td>
<td align="left">Sophie Vermeersch</td>
<td align="left">maud_raman</td>
</tr>
<tr class="even">
<td align="right">146</td>
<td align="left">MILKLIM_W&amp;Z_bermen_Leopoldkanaal</td>
<td align="left">Ecologische opvolging bermvegetaties Leopoldkanaal</td>
<td align="left">MILKLIM</td>
<td align="left">andy_vankerckvoorde</td>
</tr>
<tr class="odd">
<td align="right">148</td>
<td align="left">MILKLIM_W&amp;Z_bermen_dataW&amp;Z</td>
<td align="left">opnames in bermen door derden langs W&amp;Z-waterwegen</td>
<td align="left">W&amp;Z</td>
<td align="left">andy_vankerckvoorde</td>
</tr>
<tr class="even">
<td align="right">160</td>
<td align="left">MILKLIM_W&amp;Z_bermen_middenberm_LEO_AFL</td>
<td align="left">Ecologische opvolging van de middenberm tussen het Leopoldkanaal en het Afleidingskanaal van de Leie</td>
<td align="left">NA</td>
<td align="left">andy_vankerckvoorde</td>
</tr>
<tr class="odd">
<td align="right">186</td>
<td align="left">MILKLIM_Denderleeuw</td>
<td align="left">PQ's eilandje Denderleeuw</td>
<td align="left">Maud Raman</td>
<td align="left">maud_raman</td>
</tr>
<tr class="even">
<td align="right">203</td>
<td align="left">MILKLIM_pilootheidebekalking Braun-Blanquet</td>
<td align="left">Opvolging van pilootexperimenten heidebekalking (opnameninvoer door terreinbeheerders), opnameschaal: Braun-Blanquet</td>
<td align="left">MILKLIM</td>
<td align="left">jan_wouters</td>
</tr>
<tr class="odd">
<td align="right">215</td>
<td align="left">MILKLIM_overstromingen_DYL1999</td>
<td align="left">~ survey MILKLIM_overstromingen. Gekoppelde opnames die in 2011 opnieuw zijn gemaakt, maar enkel voor deelgebied Dijlevallei</td>
<td align="left">Siege Van Ballaert</td>
<td align="left">siege_vanballaert</td>
</tr>
<tr class="even">
<td align="right">217</td>
<td align="left">MILKLIM_Overstromingen_DYL1999_</td>
<td align="left">~ survey MILKLIM_overstromingen. Gekoppelde opnames die in 2011 opnieuw zijn gemaakt, maar enkel voor deelgebied Dijlevallei</td>
<td align="left">Siege Van Ballaert</td>
<td align="left">siege_vanballaert</td>
</tr>
</tbody>
</table>

Recording information
---------------------

The function `inboveg_recordings` queries the INBOVEG database for
relevé information (which species were recorded in which plots and in
which vegetation layers with which cover) for one or more surveys.

### Examples

Four examples are given, this can be used as base to continue selecting
the wanted data

    # get the relevés from one survey and collect the data
    recording_heischraal2012 <- inboveg_recordings(
      con, 
      survey_name = "MILKLIM_Heischraal2012", 
      collect = TRUE)

    # get all recordings from MILKLIM surveys (partial matching), don't collect
    recording_milkim <- inboveg_recordings(
      con,
      survey_name = "%MILKLIM%",
      collect = TRUE)

    # get recordings from several specific surveys
    recording_severalsurveys <- inboveg_recordings(con, survey_name =
    c("MILKLIM_Heischraal2012", "NICHE Vlaanderen"), multiple = TRUE,
    collect = TRUE)

    # get all relevés of all surveys,  don't collect the data
    allrecordings <- inboveg_recordings(con)

Header information
------------------

This function `inboveg_header`queries the INBOVEG database for header
information (metadata for a vegetation-relevé) for one survey by the
name of the survey and the recorder type.

### Examples

Two examples are given, this can be used as base to continue selecting
the wanted data

    # get header information from a specific survey and a specific recording type and collect the data
    header_info <- inboveg_header(con, survey_name = "OudeLanden_1979",
    rec_type = "Classic", collect = TRUE)

    # get header information of all surveys,  don't collect the data
    all_header_info <- inboveg_header(con)

Classification information
--------------------------

The function `inboveg_classification` queries the INBOVEG database for
information on the field classification (N2000 or BWK-code) of the
relevé for one or more survey(s) by the name of the survey.

### Examples

Two examples are given, this can be used as base to continue selecting
the wanted data

    # get a specific classification from a survey and collect the data
    classif_info <- inboveg_classification(con, 
    survey_name = "MILKLIM_Heischraal2012", classif = "4010", collect = TRUE)

    # get all surveys, all classifications,  don't collect the data
    allecodes <- inboveg_classification(con)

Qualifiers information
----------------------

This function `inboveg_qualifiers`queries the INBOVEG database for
qualifier information on recordings for one or more surveys. These
qualifiers give information on management, location description, ...

### Examples

Four examples are given, this can be used as base to continue selecting
the wanted data

    # get the qualifiers from one survey
    qualifiers_heischraal2012 <- inboveg_qualifiers(con, survey_name =
    "MILKLIM_Heischraal2012")

    # get all qualifiers from MILKLIM surveys (partial matching)
    qualifiers_milkim <- inboveg_qualifiers(con, survey_name = "%MILKLIM%")

    # get qualifiers from several specific surveys
    qualifiers_severalsurveys <- inboveg_qualifiers(con, survey_name =
    c("MILKLIM_Heischraal2012", "NICHE Vlaanderen"), multiple = TRUE)

    # get all qualifiers of all surveys
    allqualifiers <- inboveg_qualifiers(con)

More complex queries
--------------------

These functions gives the basis information out of INBOVEG. If more
precise information is needed 'dplyr' is the magic word.

### Examples

Hier nog verder uitwerken

Closing the connection
======================

Close the connection when done

    dbDisconnect(connection)
    rm(connection)
