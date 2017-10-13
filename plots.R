library(ggplot2)
library(tidyr)
library(dplyr)
library(ggthemes)
library(stringr)
library(np)
library(forcats)
library(purrr)
library(magrittr)
library(haven)

# This should be set to your working directory
setwd('C:/Intergenerational wealth')

### Intergenerational kernel plots ###

df <- read_stata('data/workdata/plot_data.dta')

# Prepare factor variable
df$gen <- as_factor(df$gen)

df <- df %>% arrange(gen)

df$gen <- fct_inorder(df$gen)

# Set bandwidth
bw = 0.12

# Define function to estimate kernel regression
kreg <- function(x) {
    npreg(as.vector(x$outcome) ~ x$r_w,
                  ckertype = 'epanechnikov',
                  bws = bw,
                  regtype = 'll')
}

# Estimate separate kernel regressions for each subplot
df <- df %>%
  nest(-gen) %>%
  mutate(fit = map(data, kreg),
    predicted = map(fit, predict)) %>%
  unnest(data, predicted)

# Figure 1
plot234 <- df %>%
  mutate_at(vars(r_w,  outcome, predicted), funs(. * 100)) %>%
  ggplot(aes(x = r_w, y = outcome)) +
    geom_smooth(method = lm, se = FALSE, linetype = 'dashed', color = 'black', size = 0.5) +
    geom_line(aes(y = predicted), color = 'blue', size = 0.7) +
    geom_rug(sides = 'b', alpha=.05) +
    facet_wrap(~gen, nrow = 3, strip.position = 'bottom') +
    theme(panel.background = element_blank(),
          panel.grid = element_blank(),
          strip.background = element_blank(),
          axis.title.x = element_blank(),
          axis.title.y = element_blank())

ggsave('figure_1.png', plot = plot234, width = 16, height = 18, units = 'cm', type = "cairo-png")


# Sensitivity analysis plot

# Read in data for imputed figures
df_imp <-
  read_stata('data/workdata/plot_data_imputed.dta') %>%
  filter(gen != 6) %>%
  mutate(gen = gen %>% as_factor %>% as.character,
         cat = "Imputed")

# Read in data for estate figures
df_est <-
  read_stata('data/workdata/plot_data_estate.dta') %>%
  filter(gen != 6) %>%
  mutate(gen = gen %>% as_factor %>% as.character,
         cat = "Estate")

# Read in main data
df_main <-
  read_stata('data/workdata/plot_data.dta') %>%
  filter(gen == 1 | gen == 3) %>%
  mutate(gen = gen %>% as_factor %>% as.character,
         cat = "Main")


df_all <-
  bind_rows(df_main, df_imp, df_est) %>%
  mutate(gen = gen %>% str_sub(4L, -1L) %>% as_factor,
         cat = cat %>% as_factor %>% fct_relevel("Main", "Estate", "Imputed"))


# Set bandwidth
bw = 0.12


# Estimate separate kernel regressions for each subplot
df_np <- df_all %>%
  nest(-gen, -cat) %>%
  mutate(fit = map(data, kreg),
    predicted = map(fit, predict)) %>%
  unnest(data, predicted)

# Online Appendix Figure 1
plot_sens <-
  df_np %>%
  mutate_at(vars(r_w,  outcome, predicted), funs(. * 100)) %>%
  ggplot(aes(x = r_w, y = outcome)) +
  geom_smooth(method = lm, se = FALSE, linetype = 'dashed', color = 'black', size = 0.5) +
  geom_line(aes(y = predicted), color = 'blue', size = 0.7) +
  #geom_smooth(method = loess, se = FALSE) +
  geom_rug(sides = 'b', alpha=.05) +
  facet_grid(cat ~ gen) +
  theme(panel.background = element_blank(),
        panel.grid = element_blank(),
        strip.background = element_blank(),
        axis.title.x = element_blank(),
        axis.title.y = element_blank())

ggsave('appendix_figure_1.png', plot = plot_sens, width = 16, height = 18, units = 'cm', type = "cairo-png")
