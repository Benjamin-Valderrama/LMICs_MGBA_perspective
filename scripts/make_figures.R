
# search term
'''
TS=("microbiome-gut-brain" OR "microbiome gut brain" OR "microbiome-gut-brain axis" OR "microbiome gut brain axis" OR "microbiota-gut-brain" OR "microbiota gut brain" OR "microbiota-gut-brain axis" OR "microbiota gut brain axis" OR ("gut microbiota" AND ("behavior" OR "behaviour" OR "cognition" OR psych* OR neuro*)))
AND DOP=(2009/2025)
AND DT=(Article OR Review)
'''
# results (20th of October 2025) sorted by oldest first:
# 14,419

# we consider 2009 as the starting year of the field due to landmark studies:
# https://doi-org.ucc.idm.oclc.org/10.1053/j.gastro.2009.01.075
# https://doi.org/10.1139/jpn.0931 
# https://doi.org/10.1016/j.biopsych.2008.06.026
# https://www.nature.com/articles/nrgastro.2009.35


# preparation -------------------------------------------------------------

library(tidyverse)
library(bibliometrix) # working with bibliography 
library(sf) # world map
library(patchwork) # put panels together

source("scripts/functions.R")

# read bibliographic data in ----------------------------------------------

paths <- list.files(path = "inputs/", pattern = "txt", full.names = TRUE)

biblio <- map(.x = paths, .f = convert2df) %>% 
  mergeDbSources()

# check missing CRs
missingData(biblio)


# get info of total pubs --------------------------------------------------

# add country info to the data
biblio_w_country <- metaTagExtraction(biblio, Field = "AU_CO", sep = ";")

total_pubs_by_country <- biblio_w_country %>% 
  select(UT, AU_CO) %>% 
  separate_longer_delim(AU_CO, delim = ";") %>% 
  unique() %>% 
  count(AU_CO, name = "total_pubs") %>% 
  arrange(desc(total_pubs)) %>% 
  mutate(log_total_pubs = log2(total_pubs)); total_pubs_by_country


# get info of international collabs ---------------------------------------

# keep only pubs that are international collabs (use custom function)
biblio_w_collabs <- biblio_w_country %>%
  mutate(international_collab = map_lgl(.x = AU_CO, 
                                        .f = is_international_collaboration)) %>% 
  filter(international_collab)

# international collabs by country
international_collabs_by_country <- biblio_w_collabs %>% 
  select(UT, AU_CO) %>% 
  separate_longer_delim(AU_CO, delim = ";") %>% 
  unique() %>% 
  count(AU_CO, name = "total_collabs") %>% 
  arrange(desc(total_collabs)) %>% 
  mutate(log_total_collabs = log2(total_collabs)) ; international_collabs_by_country


# prepare the worldmap data for plotting ----------------------------------

field_world_map <- spData::world %>% # needs the package `sf`
  mutate(AU_CO = toupper(name_long),
         AU_CO = case_when(grepl(x = AU_CO, pattern = "UNITED STATES") ~ "USA",
                           grepl(x = AU_CO, pattern = "UNITED ARAB EMIRATES") ~ "U ARAB EMIRATES",
                           grepl(x = AU_CO, pattern = "DEM. REP. KOREA") ~ "KOREA",
                           grepl(x = AU_CO, pattern = "RUSSIAN FEDERATION") ~ "RUSSIA",
                           grepl(x = AU_CO, pattern = "THE GAMBIA") ~ "GAMBIA",
                           grepl(x = AU_CO, pattern = "NORTH MACEDONIA") ~ "MACEDONIA",
                           T ~ AU_CO))

#' NOTE: MANUAL CURATION
#' What countries with international collabs have a different name in the world map?
collab_countries <- pull(.data = international_collabs_by_country, var = AU_CO)
setdiff(collab_countries, field_world_map$AU_CO)
#' Check discrepancies to fix them manually.
collab_countries %>% sort()
field_world_map$AU_CO %>% sort()


# PANEL A: World map of microbiome-gut-brain axis publications -------------

# DF to plot using international collabs info and geography
world_pubs_df <- full_join(x = field_world_map,
                           y = total_pubs_by_country, 
                           by = "AU_CO") %>% 
  filter(AU_CO != "") %>% 
  filter(AU_CO != "ANTARCTICA")

fill_scale_limits <- c(0,  max(world_pubs_df$log_total_pubs, na.rm = TRUE))
fill_scale_breaks <- seq(from = 0, 
                         to = max(world_pubs_df$log_total_pubs, na.rm = TRUE), 
                         by = 3)

# make the plot
plot_world_map_total_pubs <- world_pubs_df %>% 
  ggplot() + 
  geom_sf(aes(geometry = geom, fill = log_total_pubs)) +
  
  scale_fill_gradient(low = "#a5f370", high = "forestgreen", 
                      limits = fill_scale_limits, 
                      breaks = fill_scale_breaks,
                      na.value = "grey90") +
  labs(fill = "Log<sub>2</sub> of total<br>publications") +
  
  theme_bv() + 
  theme_void() +
  theme(legend.position = "inside",
        legend.position.inside = c(0.12, 0.3),
        legend.title = ggtext::element_markdown(size = 19),
        legend.text = element_text(size = 16.5)); plot_world_map_total_pubs

ggsave(filename = "outputs/world_map_total_pubs.jpg",
       plot = plot_world_map_total_pubs,
       height = 9, width = 12.5)


# PANEL B: World map of microbiome-gut-brain axis collaborations -----------

# DF to plot using international collabs info and geography
world_collaborations_df <- full_join(x = field_world_map,
                                     y = international_collabs_by_country, 
                                     by = "AU_CO") %>% 
  filter(AU_CO != "") %>% 
  filter(AU_CO != "ANTARCTICA")

# make the plot
plot_world_collabs_map <- world_collaborations_df %>% 
  ggplot() + 
  geom_sf(aes(geometry = geom, fill = log_total_collabs)) +
  
  scale_fill_gradient(low = "#a5f370", high = "forestgreen", 
                      limits = fill_scale_limits,
                      breaks = fill_scale_breaks,
                      na.value = "grey90") +
  labs(fill = "Log<sub>2</sub> of<br>international<br>collaborations") +
  
  theme_bv() + 
  theme_void() +
  theme(legend.position = "inside",
        legend.position.inside = c(0.12, 0.3),
        legend.title = ggtext::element_markdown(size = 15),
        legend.text = element_text(size = 13.5)); plot_world_collabs_map

ggsave(filename = "outputs/world_map_international_collabs.jpg",
       plot = plot_world_collabs_map,
       height = 9, width = 12.5)

# PANEL C: International collabs for countries within same income group -----

countries_income <- read_tsv(file = "inputs/countries_extended.tsv") %>% 
  mutate(countries = toupper(countries)) %>% 
  # we are not interested in countries where income group is not known
  filter(!is.na(income_group))

# get list of HICs, UMICs and LMICs
HICs <- filter(countries_income, income_group == "High income") %>% pull(countries) %>% sort()
UMICs <- filter(countries_income, income_group == "Upper middle income") %>% pull(countries) %>% sort()
LMICs <- filter(countries_income, grepl(x = income_group, pattern = "Low")) %>% pull(countries) %>% sort()

# type of collaborations each country has done
collabs_type_by_country <- biblio_w_collabs %>% 
  mutate(collab_type = map_chr(.x = AU_CO, 
                               .f= determine_incomes_of_collaborating_countries)) %>% 
  select(UT, PY, AU_CO, collab_type) %>% 
  separate_longer_delim(AU_CO, delim = ";") %>% 
  unique() %>% 
  count(AU_CO, collab_type, name = "n_collab_types")

# percentage of the types of collaborations
perc_collabs_type_by_country <- collabs_type_by_country %>% 
  filter(collab_type != "All income groups") %>% 
  mutate(total_collabs = sum(n_collab_types), .by = AU_CO) %>% 
  mutate(perc_collabs = n_collab_types/total_collabs) %>% 
  
  # fix order for the collaboration types
  mutate(collab_type = factor(x = collab_type,
                       levels = c("HICs_only", "UMICs_only", "LMICs_only",
                                  "HICs_LMICs", "UMICs_LMICs", "HICs_UMICs",
                                  "All income groups"),
                       
                       labels = c("HICs", "UMICs", "LMICs",
                                  "HICs and LMICs", "UMICs and LMICs", "HICs and UMICs",
                                  "All groups")))

# Plot
plot_perc_collabs_per_income_group <- perc_collabs_type_by_country %>% 
  filter(!grepl(x = collab_type, pattern = " ")) %>% 
  mutate(median = median(perc_collabs)) %>% 
  ggplot(aes(y = collab_type, x = perc_collabs)) +
  
  geom_vline(aes(xintercept = median),
             linewidth = 1.2,
             linetype = "4141", color = "grey45") +
  
  geom_point(
    size = 2, alpha = 0.8, 
    color = "grey65",
    position = position_jitter(height = .2, width = 0, seed = 1)) +
  
  stat_summary(fun.data = mean_se, 
               color = "forestgreen",
               size = 1, linewidth = 1.2) +
  
  labs(x = "International collaborations with countries\nof the same income group (%)",
       y = NULL) +
  
  scale_x_continuous(breaks = seq(0, 1, by = 0.25),
                     labels = paste0(seq(0, 100, by = 25), "%")) +
  
  theme_bv() +
  theme(
    axis.text = element_text(size = 17),
    axis.title = element_text(size = 17)
  ); plot_perc_collabs_per_income_group


ggsave(filename = "outputs/percentage_of_collabs_by_income_group.jpg",
       plot = plot_perc_collabs_per_income_group,
       height = 9, width = 12.5)


# PANEL D: Collaborations across income groups by years -------------------

collabs_per_year_df <- biblio_w_collabs %>% 
  mutate(collab_type = map_chr(.x = AU_CO, 
                               .f= determine_incomes_of_collaborating_countries)) %>% 
  count(collab_type, PY, name = "n_collabs_per_income_and_year") %>% 
  mutate(per_collabs = n_collabs_per_income_and_year/sum(n_collabs_per_income_and_year),
         .by = PY) %>% 
  filter(collab_type != "All income groups")

# collaborations between pairs of income groups
hic_and_lmic <- filter(collabs_per_year_df, !grepl(x = collab_type, pattern = "UMICs")) %>% mutate(panel = "HICs and LMICs")
hic_and_umic <- filter(collabs_per_year_df, !grepl(x = collab_type, pattern = "LMICs")) %>% mutate(panel = "HICs and UMICs")
umic_and_lmic <- filter(collabs_per_year_df, !grepl(x = collab_type, pattern = "HICs")) %>% mutate(panel = "UMICs and LMICs")

# make the data frame to plot
collabs_per_year_df_to_plot <- rbind(hic_and_lmic,
      hic_and_umic,
      umic_and_lmic) %>% 
  mutate(color = factor(x = collab_type,
                        levels = c("HICs_only",
                                   "UMICs_only",
                                   "LMICs_only",
                                   "HICs_LMICs",
                                   "UMICs_LMICs",
                                   "HICs_UMICs"),
                     
                        labels = c("HICs only",
                                   "UMICs only",
                                   "LMICs only",
                                   "Both Groups",
                                   "Both Groups",
                                   "Both Groups")),
         
        panel = factor(x = panel,
                       levels = c("HICs and UMICs", 
                                  "HICs and LMICs",
                                  "UMICs and LMICs"))
        )

years_to_plot = unique(collabs_per_year_df_to_plot$PY)

# Plot
plot_collabs_per_year <- collabs_per_year_df_to_plot %>% 
  ggplot(aes(x = PY, y = per_collabs, color = color)) +
  
  geom_line(linewidth = 1.5, alpha = 0.8) +
  geom_point(size = 2, alpha = 0.8) + 
  
  facet_wrap(.~panel) + 
  
  scale_y_continuous(expand = c(0,0), 
                     limits = c(-0.05, 1.05),
                     labels = paste0(seq(0, 100, by= 25), "%")) +
  
  scale_x_continuous(expand = c(0,0),
                     limits = c(min(years_to_plot) - 1,
                                max(years_to_plot) + 1),
                     
                     breaks = seq(min(years_to_plot),
                                  max(years_to_plot),
                                  by = 3)) +
  
  labs(x = "\nYear", y = "International\ncollaborations (%)",
       color = "Collaboration\nbetween") +
  
  scale_color_manual(values = c("grey30", "grey50", "grey70",
                                rep("forestgreen", 3))) +
  theme_bv() +
  theme(
        strip.background = element_rect(fill = "grey25"),
        strip.text = element_text(color = "white", face = "bold", size = 15),
        legend.title = ggtext::element_markdown(size = 18),
        legend.text = element_text(size = 16.5),
        axis.text = element_text(size = 15),
        axis.title = element_text(size = 17)
        ); plot_collabs_per_year

ggsave(filename = "outputs/percentage_of_collabs_by_year.jpg",
       plot = plot_collabs_per_year,
       height = 9, width = 12.5)


# Figure 1 ----------------------------------------------------------------

figure1 <- plot_world_map_total_pubs / 
  
  (plot_perc_collabs_per_income_group +
     plot_collabs_per_year +
     theme(legend.position = "inside",
           legend.position.inside = c(0.835, 0.58)) +
     plot_layout(widths = c(1, 2.7))) +
  
  plot_layout(heights = c(2.5, 1)) +
  plot_annotation(tag_levels = "A") &
  theme(plot.tag = element_text(size = 32, face = "bold")); figure1

ggsave(filename = "outputs/figure1.jpg",
       plot = figure1,
       height = 10, width = 16)
