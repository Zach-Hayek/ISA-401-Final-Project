# ISA-401-Final-Project


# Web Scraping ------------------------------------------------------------



# Scraping of 2019 GDP data
GDP2019 = 'https://statisticstimes.com/economy/world-gdp-capita-ranking.php' |> 
  rvest::read_html() |> 
  rvest::html_element("#table_id") |> 
  rvest::html_table()



# Scraping of 2023 HDI data
hdi_page = 'https://www.datapandas.org/ranking/hdi-by-country' |> 
  rvest::read_html()
country = hdi_page |> 
  rvest::html_elements(".location_list") |> 
  rvest::html_text2()
hdi = hdi_page |> 
  rvest::html_elements(".metric_list") |> 
  rvest::html_text2() 

hdi_levels = data.frame( country, hdi)
writexl::write_xlsx(hdi_levels, "hdi_levels.xlsx")



# API ---------------------------------------------------------------------

# API 
if(require(httr)==FALSE) install.packages("httr")
if(require(jsonlite)==FALSE) install.packages("jsonlite")

# WHO API endpoint for life expectancy
base_url <- "https://ghoapi.azureedge.net/api/WHOSIS_000001"

# Make the GET request
response <- httr::GET(url = base_url)

# Parse the JSON content
life_expectancy_data <- httr::content(response, as = "parsed", type = "application/json")

# Convert to a data frame
df <- jsonlite::fromJSON(jsonlite::toJSON(life_expectancy_data$value), flatten = TRUE)

# View the data
dplyr::glimpse(df)

# Filter for 2019 data (avg of both sexes)
df_2019 <- df |>
  dplyr::filter(TimeDim == 2019, Dim1 == "SEX_BTSX")

# View the filtered data
dplyr::glimpse(df_2019)

# remove non-countries
df_2019_clean <- df_2019 |>
  dplyr::filter(!SpatialDim %in% c("AFR", "AMR", "EMR", "EUR", "GLOBAL", "SEAR", "WB_HI", "WB_LI", "WB_LMI", "WB_UMI", "WPR"))

# remove unnecessary columns
life_expectancy_2019 <- df_2019_clean |>
  dplyr::select(-Id, -IndicatorCode, -SpatialDimType, -TimeDimType,
                -ParentLocationCode, -Dim1Type, -TimeDim, -Dim1,
                -Value, -Low, -High, -Date, -TimeDimensionValue,
                -TimeDimensionBegin, -TimeDimensionEnd, -ParentLocation)

# change country code (SpatialDim) to country name
install.packages("countrycode")

# Convert SpatialDim to a character vector and then apply countrycode
life_expectancy_2019 <- life_expectancy_2019 |>
  dplyr::mutate(SpatialDim = as.character(SpatialDim)) |>
  dplyr::mutate(SpatialDim = countrycode::countrycode(SpatialDim,
                                                      origin = "iso3c",
                                                      destination = "country.name"))

# Rename SpatialDim to Country and NumericValue to Life Expectancy
life_expectancy_2019 <- life_expectancy_2019 |>
  dplyr::rename(
    Country = SpatialDim,
    `Life Expectancy` = NumericValue
  )

life_expectancy_2019 =  tidyr::unnest(life_expectancy_2019)

# download the df to csv file
writexl::write_xlsx(life_expectancy_2019, "G:\\My Drive\\Senior Year\\Sem 1\\ISA401\\Final Project\\LifeExpectancyAPI2019.xlsx")



# Sources for Data --------------------------------------------------------


# here are all of the sources we used to collect data
# https://www.kaggle.com/datasets/unsdsn/world-happiness?select=2019.csv
# https://www.kaggle.com/datasets/ajaypalsinghlo/world-happiness-report-2023/data
# https://statisticstimes.com/economy/world-gdp-capita-ranking.php
# https://genderdata.worldbank.org/en/indicator/ny-gdp-pcap-cd
# https://countryeconomy.com/hdi?year=2019
# https://www.datapandas.org/ranking/hdi-by-country
# https://ghoapi.azureedge.net/api/WHOSIS_000001
# https://worldpopulationreview.com/country-rankings/life-expectancy-by-country

