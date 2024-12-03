library(tidyverse)
library(here)

kintypes_path <- here("data", "rawdata", "kinbank", "parameters.csv")
kinforms_path <- here("data", "rawdata", "kinbank", "forms.csv")
langs_path <- here("data", "rawdata", "kinbank", "languages.csv")

### KinBank

kt <- read_csv(kintypes_path)
#
kf <- read_csv(kinforms_path)
#
kl <- read_csv(langs_path) %>%
  rename(Language_ID = ID) %>%
  select(Language_ID, Glottocode, Glottolog_Name, Project)

# include only core kin types in S2 Table of Passmore et al
# deliberately drop mG, fG because we're interested in proper subsets of each group
k_siblings <- c('mB', 'mZ', 'meB', 'myB', 'meZ', 'myZ',
                'fB', 'fZ', 'feB', 'fyB', 'feZ', 'fyZ')

# siblings of parents
k_parentsiblings <- c('mMB', 'mMZ', 'mFeB', 'mFyB', 'mFeZ', 'mFyZ', 'mMeZ', 'mMyZ', 'mMeB', 'mMyB',
                      'fMB', 'fMZ', 'fFeB', 'fFyB', 'fFeZ', 'fFyZ', 'fMeZ', 'fMyZ', 'fMeB', 'fMyB')
# grandparents
# deliberately drop PP because we're interested in proper subsets of each group
k_grandparents <- c("mFF", "mFM", "mMF", "mMM",
                    "fFF", "fFM", "fMF", "fMM")

# grandchildren
# deliberately drop CC because we're interested in proper subsets of each group
k_grandchildren <- c("mSS", "mSD", "mDS", "mDD",
                     "fSS", "fSD", "fDS", "fDD")

# niece/nephews GOOD
k_niecenephews <- c("mBS", "mBD", "mZS", "mZD", "meBS", "myBS", "meBD", "myBD", "meZS", "myZS", "meZD", "myZD",
                    "fBS", "fBD", "fZS", "fZD", "feBS", "fyBS", "feBD", "fyBD", "feZS", "fyZS", "feZD", "fyZD")


# cousins

k_cousins<- c("mFZD", "mFBD", "mBD", "mZD", "mFBS", "mFZS", "mMBS", "mMZS",
              "mFeBS", "mFyBS", "mFeZS", "mFyZS", "mFeBD", "mFyBD", "mFeZD", "mFyZD",
              "mMeBS", "mMyBS", "mMeZS", "mMyZS", "mMeBD", "mMyBD", "mMeZD", "mMyZD",
              "mFBeS", "mFByS", "mFZeS", "mFZyS", "mFBeD", "mFByD", "mFZeD", "mFZyd",
              "mMBeS", "mMByS", "mMZeS", "mMZyS", "mMBeD", "mMByD", "mMZeD", "mMZyd",
              "fFZD", "fFBD", "fBD", "fZD", "fFBS", "fFZS", "fMBS", "fMZS",
              "fFeBS", "fFyBS", "fFeZS", "fFyZS", "fFeBD", "fFyBD", "fFeZD", "fFyZD",
              "fMeBS", "fMyBS", "fMeZS", "fMyZS", "fMeBD", "fMyBD", "fMeZD", "fMyZD",
              "fFBeS", "fFByS", "fFZeS", "fFZyS", "fFBeD", "fFByD", "fFZeD", "fFZyd",
              "fMBeS", "fMByS", "fMZeS", "fMZyS", "fMBeD", "fMByD", "fMZeD", "fMZyd")

# Counting kintypes covered by each languages doesn't seem right because terms for male speakers and female speakers are separated.
# Counting forms also not right because of dialectal variants
# So we'll count number of extensions per language

all_lists <- list(k_siblings, k_parentsiblings, k_grandparents, k_grandchildren, k_niecenephews, k_cousins)


all_systems <- tibble()
all_size <- tibble()
all_parity <- tibble()

for (i in  1:length(all_lists)) {
  focal_i <- all_lists[[i]]
  name_i <- list_names[i]
  kb_focal <- kf %>%
    select(Language_ID, Parameter_ID, Form) %>%
    filter(Parameter_ID %in% focal_i) %>%
    left_join(kl, by = "Language_ID")

  kb_counts <- kb_focal %>%
    group_by(Language_ID, Glottocode, Glottolog_Name, Form) %>%
    nest() %>%
    ungroup() %>%
    select(-Form) %>%
    unique() %>%
    group_by(Language_ID, Glottocode, Glottolog_Name) %>%
    summarize(size = n()) %>%
    mutate(class = name_i)

  kb_sizes <- kb_counts %>%
    group_by(size, class) %>%
    summarize(count= n()) %>%
    ungroup() %>%
    mutate(parity = factor(size%% 2, label= c("even", "odd")))

  parity_stats <- kb_sizes %>%
    filter(size > 1) %>%   # drop any systems with no category divisons
    group_by(parity, class) %>%
    summarize(count = sum(count))

  all_systems <- bind_rows(all_systems, kb_counts )
  all_size <- bind_rows(all_size, kb_sizes)
  all_parity <- bind_rows(all_parity, parity_stats)
}

count_plot %+%  ( all_size %>%  mutate(class = factor(class, levels = list_names)) )


kb_kinship <- all_systems %>%
  rename(glottocode=Glottocode, glottolog_name = Glottolog_Name, language_ID =Language_ID) %>%
  write_csv(here("data", "kinbank_kinship.csv"))

