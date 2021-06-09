library(readr)
library(tidy)

#Url: https://www.cms.gov/Research-Statistics-Data-and-Systems/Statistics-Trends-and-Reports/Medicare-Provider-Charge-Data/OpioidMap.html



# This will get data into global environment
cdcDeathCauses <- read_delim("data/cdcDeathCauses", 
                             "\t", escape_double = FALSE, trim_ws = TRUE)

cdcDeathCauses <- cdcDeathCauses[,-1]


# Get's this ready for the map plot
states <- map_data("state")

# Fixes the axes for the plot
ditch_the_axes <- theme(
  axis.text = element_blank(),
  axis.line = element_blank(),
  axis.ticks = element_blank(),
  panel.border = element_blank(),
  panel.grid = element_blank(),
  axis.title = element_blank()
)

# Creates data frame for the plot
deathPercByStateData <-
  cdcDeathCauses %>%
  mutate(deathPerc = (Deaths/Population) * 100) %>%
  mutate(crudeRate = parse_number(`Crude Rate`)) %>%
  mutate(ageAdjRate = parse_number(`Age Adjusted Rate`)) %>%
  arrange(desc(deathPerc)) %>% 
  mutate(region = `State`, region = tolower(region)) %>% 
  filter(State != "District of Columbia") %>% 
  inner_join(states, by = "region") %>%
  select(State, Year, Deaths, Population, deathPerc, crudeRate, ageAdjRate, region, lat,
         long, group)

#Gets the opioid prescription data
df_2013 <- read_excel("data/Medicare_Part_D_Opioid_Prescribing_Geographic_2013.xlsx", 
                      skip = 4)

df_2014 <- read_excel("data/Medicare_Part_D_Opioid_Prescribing_Geographic_2014.xlsx", 
                      skip = 4)

df_2015 <- read_excel("data/Medicare_Part_D_Opioid_Prescribing_Geographic_2015.xlsx", 
                      skip = 4)

df_2016 <- read_excel("data/Medicare_Part_D_Opioid_Prescribing_Geographic_2016.xlsx", 
                      skip = 4)

#Binds them together
df <- 
  df_2013 %>% 
  bind_rows(df_2014) %>% 
  bind_rows(df_2015) %>% 
  bind_rows(df_2016)

# Removes unnecessary data
df <-
  df[-c(1,53,105,157), c(1,2,9,10,11,12)]

# Creates a year variable
df <-
  df %>% 
  mutate(year = rep(2013:2016 ,each = 51))


# Fixes the names
names(df) <-
  c("State", "state_abb", "op_rate", "extended_op_rate", "op_rate_change", "extended_op_rate_change", "Year")

# Makes data recent
cdcDeathCauses <-
  cdcDeathCauses %>%
  filter(Year > 2005)

# Creates new data frame for the prescription rate graphs
cdcNew <-
  cdcDeathCauses %>%
  mutate(deathPerc = parse_number(cdcDeathCauses$`% of Total Deaths`)) %>%
  mutate(crudeRate = parse_number(cdcDeathCauses$`Crude Rate`)) %>%
  mutate(ageAdjRate = parse_number(cdcDeathCauses$`Age Adjusted Rate`)) %>%
  select(State, Year, Deaths, Population, deathPerc, crudeRate, ageAdjRate) %>% 
  mutate(DeathperPop = (Deaths/Population)*100) %>% 
  mutate(region = `State`, region = tolower(region)) %>% 
  filter(State != "District of Columbia")

# Joins them together
dfNew <- 
  df %>% 
  inner_join(cdcNew, by = c("State", "Year"))


save(dfNew, file = "data/intendedData.rda")
save(deathPercByStateData, file = "data/intendedDataPartTwo.rda")
save(ditch_the_axes, file = "data/ditchtheaxes.rda")
