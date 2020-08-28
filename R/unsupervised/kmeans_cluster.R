# DS4B 101-R: R FOR BUSINESS ANALYSIS ----
# CUSTOMER SEGMENTATION ----


library(tidyverse)
library(broom)
library(umap)
library(ggrepel)
library(tidyquant)

bike_orderlines_tbl <- read_rds("../data/bike_orderlines.rds")

glimpse(bike_orderlines_tbl)


# 1.0 CUSTOMER TRENDS ----
# - GOAL: Mine Customer Purchase History for similarity to other "like" customers
# - TECHNIQUES: K-Means Clustering, UMAP 2D Projection

# 1.1 Get Customer Trends ----

# PRO-TIP: When understanding customer trends, collect unique customer name, product attributes and quantity/total prices
# PRO-TIP: Convert customer trends by aggregating within customer-product groups, then Normalizing within customer groups to get % of each product purchased by customer

customer_trends_tbl <- bike_orderlines_tbl %>%
    select(bikeshop_name, price, model, category_1, category_2, frame_material, quantity) %>%
    # Summarization & Group By
    # aggregating within customer-product group
    group_by(bikeshop_name, price, model, category_1, category_2, frame_material) %>%
    summarize(quantity_purchased = sum(quantity)) %>%
    ungroup() %>%

    # NORMALIZATION - customer purchase by proportion (prop_of_total)
    group_by(bikeshop_name) %>%
    mutate(prop_of_total = quantity_purchased / sum(quantity_purchased)) %>%
    ungroup()

customer_trends_tbl

# 1.2 Convert to User-Item Format (e.g. Customer-Product) ----

customer_product_tbl <- customer_trends_tbl %>%
    select(bikeshop_name, model, prop_of_total) %>%
    # User-Item Format with spread() function from tidyr
    spread(key = model, value = prop_of_total, fill = 0)
    
    
customer_product_tbl

# 2.0 MODELING: K-MEANS CLUSTERING ----

# 2.1 Performing K-Means ----
?kmeans

# NOTE: Because this is unsupervised algorithm, we need to tell how many groups to classify


kmeans_obj <- customer_product_tbl %>%
    select(-bikeshop_name) %>%
    kmeans(centers = 5, nstart = 100)

kmeans_obj$centers

# 2.2 Tidying a K-Means Object ----

# tidy() functions gives us 'centers' information for K-Means object
broom::tidy(kmeans_obj) %>% glimpse()

# glance() function gives us summary metrics for the model (total sum sq, total within sum sq, between sum sq and iterations)
# NOTE: we will use total within sum sq (tot.withinss) to determine what number of clusters to use

broom::glance(kmeans_obj)

broom::augment(kmeans_obj, customer_product_tbl) %>%
    # .cluster is the cluster assignment that kmeans algo assign
    select(bikeshop_name, .cluster)

# 2.3 How many centers (customer groups) to use? ----
 
# STEP 1: Create funcion that can be iterated (make kmeans mapper)

# Function that works on ONE element
center <- 3

kmeans_mapper <- function(centers = 3){
    customer_product_tbl %>%
        select(-bikeshop_name) %>%
        kmeans(centers = centers, nstart = 100)
}

# PRO TIP: Test your function on a single iteration (test with centers = 3)
# this allows us to get total sum of square

3 %>% kmeans_mapper() %>% glance()

# STEP 2: Implement purrr row-wise ( use mutate() + map() )
# Pro-Tip: Can also apply broom::glance() row-wise with mutate() + map()

# Mapping the function to MANY elements

kmeans_mapped_tbl <- tibble(centers = 1:15) %>%
    mutate(k_means = centers %>% map(kmeans_mapper)) %>%
    mutate(glance = k_means %>% map(glance))

# STEP 3: Unnest the glance column

kmeans_mapped_tbl %>%
    unnest(glance) %>%
    select(centers, tot.withinss)


# 2.4 Skree Plot ----
# GOAL is Scree Plot: to calculate total within sum of squares (tot.withinss) for many centers

kmeans_mapped_tbl %>%
    unnest(glance) %>%
    select(centers, tot.withinss) %>%
    
    # Visualization
    ggplot(aes(x = centers, y = tot.withinss)) +
    geom_point(color = '#2c3e50', size = 4) +
    geom_line(color = '#2c3e50', size = 1) +
    ggrepel::geom_label_repel(aes(label = centers), color = '#2c3e50') +
    
    # Formatting
    theme_tq() +
    labs(
        title = 'Skree Plot',
        subtitle = 'Measures the distance that each customer are from the closest K-Means center',
        caption = 'Conclusion: Based on Skree Plot (elbow), we will select 4 clusters to segment customer base'
    )


# 3.0 VISUALIZATION: UMAP ----

# 3.1 Use UMAP to get 2-D Projection ----

# NOTE: UMAP is similar to PCA; a dimensionality reduction technique that captures the structure
# of a high-dimension data set (many numeric columns, like customer_product_tbl) in a 
# two column (x and y) data set

# NOTE: each Umap project involves randomness so the plots might look different
?umap

umap_obj <- customer_product_tbl %>%
    select(-bikeshop_name) %>%
    umap()

umap_results_tbl <- umap_obj$layout %>%
    as_tibble() %>%
    set_names(c("x", "y")) %>%
    bind_cols(
        customer_product_tbl %>% select(bikeshop_name)
    )

umap_results_tbl %>%
    ggplot(aes(x = x, y = y)) +
    geom_point() +
    geom_label_repel(aes(label = bikeshop_name), size = 3)

# 3.2 Use K-Means to Add Cluster Assignments ----

umap_results_tbl

kmeans_4_obj <- kmeans_mapped_tbl %>%
    # pull the 'list' of k-means objects
    pull(k_means) %>%
    pluck(4)

kmeans_4_clusters_tbl <- kmeans_4_obj %>% 
    augment(customer_product_tbl) %>%
    select(bikeshop_name, .cluster)

# join with umap_results

umap_kmeans_4_results_tbl <- umap_results_tbl %>%
    left_join(kmeans_4_clusters_tbl)


# alternative
kmeans_mapped_tbl %>%
    filter(centers == 4) %>%
    pull(k_means) %>%
    pluck(1)

# 3.3 Visualize UMAP'ed Projections with Cluster Assignments ----

umap_kmeans_4_results_tbl %>%
    mutate(label_text = str_glue("Customer: {bikeshop_name}
                                 Cluster: {.cluster}")) %>%
    ggplot(aes(x = x, y = y, color = .cluster)) +
    
    # Geometries
    geom_point() + 
    geom_label_repel(aes(label = label_text), size = 3) +
    
    # Formatting
    theme_tq() + 
    scale_color_tq() +
    labs(
        title = 'Customer Segmentation: 2D Projection',
        subtitle = 'UMAP 2D Projection with K-Means Cluster Assignment',
        caption = 'Conclusion: 4 Customer Segments identified using 2 algorithms'
    ) +
    theme(legend.position = 'none')


# 4.0 ANALYZE PURCHASING TRENDS ----

# What are the customers WITHIN the clusters buying?

# instead of bikeshop_name, we want cluster

cluster_trends_tbl <- customer_trends_tbl %>%
    # Step 1: Join Cluster Assignment by bikeshop_name
    left_join(umap_kmeans_4_results_tbl) %>% 
    # Step 2a: Assigning Bins
    mutate(price_bin = case_when(
        price <= 2240 ~ 'low',
        price <= 4260 ~ 'medium',
        TRUE ~ 'high'
    )) %>% 
    # Step 3: Select needed columns
    select(.cluster, model, contains("price"), 
           category_1:quantity_purchased) %>%
    
    # Step 4: Aggregation quantity purchased by cluster and product attributes
    group_by_at(.vars = vars(.cluster:frame_material)) %>%
    summarize(total_quantity = sum(quantity_purchased)) %>%
    ungroup() %>%
    
    # Step 5: Normalization - Calculate Proportion of Total
    group_by(.cluster) %>%
    mutate(prop_of_total = total_quantity / sum(total_quantity)) %>%
    ungroup()

cluster_trends_tbl


# Step 2: Binning Price (low, med, high)
# determine low (below 2240), medium (below 4260), high (above 4260)
customer_trends_tbl %>%
    pull(price) %>%
    # low, medium, high
    quantile(probs = c(0, 0.33, 0.66, 1))


# Step 6: Trend Analysis Cluster 1

# Cluster 1 - Low/Medium Price, Road Model Preferences
cluster_trends_tbl %>%
    filter(.cluster == 1) %>%
    arrange(desc(prop_of_total)) %>%
    mutate(cum_prop = cumsum(prop_of_total)) 

get_cluster_trends <- function(cluster = 1) {
    
    cluster_trends_tbl %>%
        filter(.cluster == cluster) %>%
        arrange(desc(prop_of_total)) %>%
        mutate(cum_prop = cumsum(prop_of_total)) 
    
}

# Cluster 2: Medium Price, Mountain Model Preference, Alumininum
get_cluster_trends(cluster = 2) %>% view()

# Cluster 3: High End Price, Road Preference, Carbon
get_cluster_trends(cluster = 3) %>% view()

# Cluster 4: Low End, Mountain, Aluminum Frame
get_cluster_trends(cluster = 4) %>% view()

# Update Visualization ----

# create cluster label
cluster_label_tbl <- tibble(
    .cluster = 1:4,
    .cluster_label = c(
        "Low/Medium Price, Road Model Preferences",
        "Medium Price, Mountain Model Preference, Alumininum",
        "High End Price, Road Preference, Carbon",
        "Low End, Mountain, Aluminum Frame"
    )
) %>%
    # pro-tip: numeric data cannot be directly converted to factor
    # numeric must be converted to character first before converting to factor
    mutate(.cluster = as_factor(as.character(.cluster)))

cluster_label_tbl

# left join with cluster_label_tbl
umap_kmeans_4_results_tbl %>%
    left_join(cluster_label_tbl)

# add cluster labels via left_join
umap_kmeans_4_results_tbl %>%
    left_join(cluster_label_tbl) %>%
    mutate(label_text = str_glue("Customer: {bikeshop_name}
                                 Cluster: {.cluster}
                                 {.cluster_label}")) %>%
    ggplot(aes(x = x, y = y, color = .cluster)) +
    
    # Geometries
    geom_point() + 
    geom_label_repel(aes(label = label_text), size = 3) +
    
    # Formatting
    theme_tq() + 
    scale_color_tq() +
    labs(
        title = 'Customer Segmentation: 2D Projection',
        subtitle = 'UMAP 2D Projection with K-Means Cluster Assignment',
        caption = 'Conclusion: 4 Customer Segments identified using 2 algorithms'
    ) +
    theme(legend.position = 'none')