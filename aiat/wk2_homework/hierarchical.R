
library(ggraph)
library(igraph)
library(tidyverse)

# Airbnb Data from Kaggle 
df <- read_csv("AB_NYC_2019.csv")

df %>%
    select(host_id, neighbourhood_group, neighbourhood) %>%
    group_by(host_id) %>%
    tally(sort = TRUE)
    
# airbnb group by neighborhood_group
df %>%
    select(host_id, neighbourhood_group, neighbourhood) %>%
    group_by(neighbourhood_group) %>%
    tally(sort = TRUE)

# Group by neighbourhood
df %>%
    select(host_id, neighbourhood_group, neighbourhood) %>%
    group_by(neighbourhood) %>%
    tally(sort = TRUE)

# Nested Data Frame Approach ----

# create a nested data frame 
nested_data <- data.frame(
    level1="CEO",
    level2=c( rep("boss1",4), rep("boss2",4)),
    level3=paste0("mister_", letters[1:8])
)

# transform it to a edge list!
edges_level1_2 <- nested_data %>% select(level1, level2) %>% unique %>% rename(from=level1, to=level2)
edges_level2_3 <- nested_data %>% select(level2, level3) %>% unique %>% rename(from=level2, to=level3)
edge_list=rbind(edges_level1_2, edges_level2_3)

# Now we can plot that
mygraph <- graph_from_data_frame( edge_list )
ggraph(mygraph, layout = 'dendrogram', circular = FALSE) + 
    geom_edge_diagonal() +
    geom_node_point() +
    theme_void()


# Matrix Approach ----

# Hierarchical Clustering 
data <- matrix( sample(seq(1,2000),200), ncol = 10 )
rownames(data) <- paste0("sample_" , seq(1,20))
colnames(data) <- paste0("variable",seq(1,10))

# Euclidean Distance
dist <- dist(data[ , c(4:8)] , diag=TRUE)

# Hierarchical Clustering with hclust
hc <- hclust(dist)

# Plot the result
plot(hc)
