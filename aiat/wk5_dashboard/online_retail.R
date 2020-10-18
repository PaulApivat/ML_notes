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
p1 <- retail2 %>%
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
    ggplot(aes(x = reorder(Country, Total_Revenue), y = Total_Revenue, fill = Country)) +
    geom_col() +
    coord_flip() +
    scale_y_continuous(labels = scales::dollar_format()) +
    theme_classic() +
    theme(
        legend.position = "none"
    ) +
    labs(
        y = 'Total Revenue',
        x = 'Countries',
        title = 'Top Revenue Generating Countries',
        subtitle = 'Not including the United Kingdom'
    ) 




# product StockCode for UK
# need to remove legend (too many observations)
# pie chart - not informative
retail2 %>%
    select(StockCode, Country) %>%
    group_by(StockCode, Country) %>%
    tally(sort = TRUE) %>%
    filter(Country == 'United Kingdom') %>%
    ggplot(aes(x="", y=n, fill=StockCode)) +
    geom_bar(stat = 'identity', width = 1) +
    coord_polar("y", start = 0) +
    theme(legend.position = "none")


retail2 %>%
    group_by(InvoiceNo) %>%
    tally(sort = TRUE)

# top 10 Product Descriptions  by frequency across all countries
retail2 %>%
    group_by(Description) %>%
    tally(sort = TRUE) %>%
    head(10)

# top 10 products by revenue - across 10 countries
p2 <- retail2 %>%
    select(Description, Quantity, UnitPrice) %>%
    mutate(
        Total_Revenue = Quantity * UnitPrice
    ) %>%
    group_by(Description) %>%
    summarise(
        Sum_Revenue = sum(Total_Revenue)
    ) %>%
    arrange(desc(Sum_Revenue)) %>%
    head(10) %>%
    ggplot(aes(x = reorder(Description, Sum_Revenue), y = Sum_Revenue, fill = Description)) +
    geom_col() +
    scale_y_continuous(labels = scales::dollar_format()) +
    theme_classic() +
    theme(
        axis.text.x = element_text(angle = 45, hjust = 1),
        legend.position = "none"
        ) +
    labs(
        title = "Top 10 Product by Revenue",
        y = "Total Revenue",
        x = "Product Descriptions"
    )
    

# DOTCOM POSTAGE sales over time
library(lubridate)

p3 <- retail2 %>%
    select(Description, Quantity, UnitPrice, InvoiceDate) %>%
    mutate(
        Revenue = Quantity * UnitPrice,
        InvoiceDate = InvoiceDate %>% mdy_hm()
    ) %>%
    filter(Description == 'DOTCOM POSTAGE') %>%
    ggplot(aes(x = InvoiceDate, y = Revenue)) + 
    geom_line() +
    theme_classic() +
    scale_y_continuous(labels = scales::dollar_format()) +
    labs(
        x = "Date",
        title = "Best Selling Product: Dotcom Postage Revenue",
        subtitle = "12/1/2010 - 12/9/2011"
    )

# Spaceboy Lunch Box Revenue facet by country
p4 <- retail2 %>%
    select(Description, Quantity, UnitPrice, InvoiceDate, Country) %>%
    mutate(
        Revenue = Quantity * UnitPrice,
        InvoiceDate = InvoiceDate %>% mdy_hm()
    ) %>% 
    filter(Description == 'SPACEBOY LUNCH BOX') %>% 
    ggplot(aes(x = InvoiceDate, y = Revenue, group = Country)) +
    geom_line() +
    theme_classic() +
    scale_y_continuous(labels = scales::dollar_format()) +
    facet_wrap(~Country) +
    labs(
        x = "Date",
        title = "Spaceboy Lunch Box Revenue by Country",
        subtitle = "Time Period: 12/1/2010 - 12/9/2011"
    )

# Top revenue generating products, over 5000, by countries outside of UK
p5 <- retail2 %>%
    select(Description, Quantity, UnitPrice, Country) %>%
    mutate(
        Total_Revenue = Quantity * UnitPrice
    ) %>%
    group_by(Country, Description) %>%
    summarise(
        Sum_Revenue = sum(Total_Revenue)
    ) %>%
    arrange(desc(Sum_Revenue)) %>% 
    filter(Country != 'United Kingdom') %>%
    filter(Sum_Revenue > 5000) %>% 
    ggplot(aes(x = Description, y = Sum_Revenue, fill = Description)) + 
    geom_col() +
    facet_wrap(~Country) +
    theme_classic() +
    theme(
        axis.text.x = element_text(angle = 90, hjust = 1),
        legend.position = 'none'
    ) +
    scale_y_continuous(labels = scales::dollar_format()) +
    coord_flip() +
    labs(
        x = 'Products',
        y = 'Total Revenue',
        title = 'Top Revenue Generating Products Outside of the UK',
        subtitle = 'Grossing over $5,000'
    )
    


# dashboard creation
library(patchwork)

p5 + (p1 / (p2 + p3))
