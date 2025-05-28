library(tidyverse)
library(here)

kin_murdock_path <- here("data", "rawdata", "murdock_kinship", "rwpartitions.txt")

# The Murdock data file has missing data for great grandparents

gg_codes<- c("X2", "X3", "X4", "X5", "X6", "X7", "X8", "X9",
             "X58", "X59", "X60", "X61", "X62", "X63", "X64", "X65")

# siblings
m_siblings <- c("X32", "X33", "X34", "X35", "X88", "X89", "X90", "X91")

# siblings of parents
m_parentsiblings <- c("X14", "X15", "X17", "X18", "X19", "X20", "X22", "X23",
            "X70", "X71", "X73", "X74", "X75", "X76", "X78", "X79")

# grandparents
m_grandparents <- c("X10", "X11", "X12", "X13", "X66", "X67", "X68", "X69")

# grandchildren
m_grandchildren <- c("X54", "X55", "X56", "X57", "X110", "X111", "X112", "X113")

# niece/nephews
#m_niecenephews<- c("X44", "X45", "X46", "X47", "X50", "X51", "X52", "X53",
m_niecenephews<- c("X100", "X101", "X102", "X103", "X106", "X107", "X108", "X109")

# cousins
clist = c()
for (i in seq(24,31)) {
   clist <- c(clist, paste0("X", as.character(i)))
}
for (i in seq(36,43)) {
   clist <- c(clist, paste0("X", as.character(i)))
}
for (i in seq(80,87)) {
   clist <- c(clist, paste0("X", as.character(i)))
}
for (i in seq(92,99)) {
   clist <- c(clist, paste0("X", as.character(i)))
}

m_cousins <- clist

all_lists <- list(m_siblings, m_parentsiblings, m_grandparents, m_grandchildren, m_niecenephews, m_cousins)
list_names <- c("siblings", "parent_siblings", "grandparents", "grandchildren", "nieces_nephews", "cousins")

km <- read_table(kin_murdock_path, col_names = FALSE) %>%
  select(-all_of(gg_codes)) %>%
  mutate(system_id = row_number()) %>%
  rename(freq=X1) %>%
  pivot_longer(cols = 2:last_col(offset = 1), names_to = "kintype", values_to = "label")

all_size <- tibble()
all_parity <- tibble()

for (i in  1:length(all_lists)) {
  focal_i <- all_lists[[i]]
  name_i <- list_names[i]
  km_focal <- km %>%
    filter(kintype %in% focal_i)

  km_counts <- km_focal %>%
    group_by(system_id) %>%
    mutate(minval = min(label)) %>%
    ungroup() %>%
    filter(minval > 0) %>%    # drop any system with missing data
    group_by(system_id, freq) %>%
    summarize(size = length(unique(label))) %>%
    mutate(class = name_i)

  km_sizes <- km_counts %>%
    group_by(size, class) %>%
    summarize(count= sum(freq)) %>%
    ungroup() %>%
    mutate(parity = factor(size%% 2, label= c("even", "odd")))

  parity_stats <- km_sizes %>%
    filter(size > 1) %>%   # drop any systems with no category divisons
    group_by(parity, class) %>%
    summarize(count = sum(count))

  all_size <- bind_rows(all_size, km_sizes)
  all_parity <- bind_rows(all_parity, parity_stats)
}

all_size <- all_size %>%
  mutate(class = factor(class, levels = list_names)) %>%
  select(class, size, count) %>%
  write_csv(here("data", "murdock_kinship.csv"))

all_parity <- all_parity %>%
  mutate(class = factor(class, levels = list_names))

count_plot <- all_size %>%
  ggplot(aes(x=size, y = count, fill=parity, color=parity)) +
  geom_bar(stat = "identity") +
  facet_wrap(~class)

count_plot
