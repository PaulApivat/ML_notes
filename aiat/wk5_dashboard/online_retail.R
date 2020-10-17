library(tidyverse)

# read data
retail <- read_csv("Online_Retail.csv")

# exploratory
str(retail)

# get rid of row 293621 parsing failure
retail[293621,]

retail2 <- retail %>%
    slice(-c(293621))

retail2 %>% str()

# check missing data ----

# total missing data
retail2 %>%
    summarise(sum(is.na(.)))

summary(retail2)

# column wise
# note: Description (missing 592), CustomerID (missing 133358)
sapply(retail2, function(x) sum(is.na(x)))

# or
colSums(is.na(retail2))


retail2 %>%
    sapply(function(x) sum(is.na(x)))

# row wise
# row missing (133358, same as CustomerID)
sum(!complete.cases(retail2))


# check unique values per column (or duplication) ----

# InvoiceNo   StockCode Description    Quantity InvoiceDate   UnitPrice  CustomerID     Country 
# 20725        3940        4065         393       19050        1291        4340          38 

apply(retail2, 2, function(x) length(unique(x)))


# describe data quickly ----

retail2 %>%
    head()

# unique countries (with and without UK)

retail2 %>%
    group_by(Country) %>%
    filter(Country != 'United Kingdom') %>%
    tally(sort = TRUE)
    

# Bar chart total revenue by country
retail2 %>%
    mutate(
        Revenue = Quantity * UnitPrice
    ) %>%
    group_by(Country) %>%
    summarize(
        Total_Revenue = sum(Revenue)
    ) %>%
    ungroup() %>%
    arrange(desc(Total_Revenue)) %>%
    filter(Country != 'United Kingdom') %>%
    ggplot(aes(x = reorder(Country, Total_Revenue), y = Total_Revenue, fill = Total_Revenue)) +
    geom_col() +
    coord_flip() 

# product StockCode for UK
# need to remove legend (too many observations)
retail2 %>%
    select(StockCode, Country) %>%
    group_by(StockCode, Country) %>%
    tally(sort = TRUE) %>%
    filter(Country == 'United Kingdom') %>%
    ggplot(aes(x="", y=n, fill=StockCode)) +
    geom_bar(stat = 'identity', width = 1) +
    coord_polar("y", start = 0) +
    theme(legend.position = "none")




