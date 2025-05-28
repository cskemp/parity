library(tidyverse)
library(here)
library(stringi)

kintypes_path <- here("data", "rawdata", "kinbank", "parameters.csv")
kinforms_path <- here("data", "rawdata", "kinbank", "forms.csv")
langs_path <- here("data", "rawdata", "kinbank", "languages.csv")

## function based on get_termsubsets.R, written by Sam Passmore and released as
## part of the materials accompanying Passmore (2023), The global recurrence and
## variability of kinship terminology structure

clean_kinterms = function(kinterm){
  kinterm = tolower(kinterm)
  ## if terms are in brackets - assume that is an alternative term and remove it
  kinterm = stringr::str_remove_all(kinterm, "\\(.*\\)")
  ## if terms are seperated by semi-colons or commas, take everything before them
  kinterm = gsub("^(.*?)(,|;).*", "\\1", kinterm)
  ## remove whitespace
  kinterm = stringi::stri_replace_all_charclass(kinterm, "\\p{WHITE_SPACE}", "")
  ## normalize in case there are inconsistent diacritics, etc
  kinterm = stri_trans_nfc(kinterm)
  kinterm
}

### KinBank

kt <- read_csv(kintypes_path)
kf <- read_csv(kinforms_path)
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
              "mFBeS", "mFByS", "mFZeS", "mFZyS", "mFBeD", "mFByD", "mFZeD", "mFZyD",
              "mMBeS", "mMByS", "mMZeS", "mMZyS", "mMBeD", "mMByD", "mMZeD", "mMZyD",
              "fFZD", "fFBD", "fBD", "fZD", "fFBS", "fFZS", "fMBS", "fMZS",
              "fFeBS", "fFyBS", "fFeZS", "fFyZS", "fFeBD", "fFyBD", "fFeZD", "fFyZD",
              "fMeBS", "fMyBS", "fMeZS", "fMyZS", "fMeBD", "fMyBD", "fMeZD", "fMyZD",
              "fFBeS", "fFByS", "fFZeS", "fFZyS", "fFBeD", "fFByD", "fFZeD", "fFZyD",
              "fMBeS", "fMByS", "fMZeS", "fMZyS", "fMBeD", "fMByD", "fMZeD", "fMZyD")

# Counting kintypes covered by each language doesn't seem right because terms for male speakers and female speakers are separated.
# Counting forms also not right because of dialectal variants
# So we'll count number of extensions per language

all_lists <- list(k_siblings, k_parentsiblings, k_grandparents, k_grandchildren, k_niecenephews, k_cousins)
list_names <- c("siblings", "parent_siblings", "grandparents", "grandchildren", "nieces_nephews", "cousins")

all_systems <- tibble()
all_size <- tibble()
all_parity <- tibble()

for (i in  1:length(all_lists)) {
  focal_i <- all_lists[[i]]
  name_i <- list_names[i]
  kb_focal <- kf %>%
    select(Language_ID, Parameter_ID, Form) %>%
    filter(Parameter_ID %in% focal_i) %>%
    mutate(Form = clean_kinterms(Form)) %>%
    left_join(kl, by = "Language_ID")

  kb_counts <- kb_focal %>%
    group_by(Language_ID, Glottocode, Glottolog_Name, Form) %>%
    nest() %>%
    # some forms are listed twice and attributed to different sources (e.g. bana:m for band1339) -- so drop duplicates
    # also need to sort data to ensure that forms are in a canonical order
    mutate(data = map(data, ~ .x %>% distinct() %>% arrange(Parameter_ID))) %>%
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


kb_kinship <- all_systems %>%
  rename(glottocode=Glottocode, glottolog_name = Glottolog_Name, language_ID =Language_ID) %>%
  # one glottocode doesn't appear in Glottolog -- so replace tupi1239 with tupi1276
  # Sam Passmore suggested that we should perhaps remove tupi1276 because it is a reconstructed rather than a documented language. But
  # I've left it in because there seem to be other reconstructed languages (Proto-Oceanic, Proto-Sogeram) -- seemed simpler to keep them
  # rather than remove them all
  mutate(glottocode = case_when(
    glottocode == "tupi1239" ~ "tupi1276",
    TRUE ~ glottocode
  )) %>%
  write_csv(here("data", "kinbank_kinship.csv"))
