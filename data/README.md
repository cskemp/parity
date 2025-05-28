## Data 

This folder includes data files for all domains except for color. 

### Deictic day names

Day naming data were transcribed from Tent, J. (1998). The structure of deictic day-name systems. Studia Linguistica, 52(2):112–148.

### Tense

Tense data were transcribed from the database released along with Velupillai, V. (2016). Partitioning the timeline: A cross-linguistic survey of tense. Studies in Language, 40(1):93–136.

### Seasons

Season naming data were analyzed in Kemp, C., Gaby, A., and Regier, T. (2019). Season naming and the local environment, and are released here for the first time. The data set included here includes information about the sizes of 54 season systems. The 2019 paper also analyzed a separate data set (not included here) that specified information about season boundaries for a smaller number of systems.

### Moon Phases

Moon phase data are released here for the first time.  A complete version of the moon phase data is included in `rawdata/moon_phases/`

### Locational systems
`ozspace_sizes.csv` is derived from the original data base of locational systems provided by Dorothea Hoffmann, Bill Palmer and Alice Gaby. This data base is not included in this repository.

### Kinship

Kinship data were drawn from Kinbank and a dataset compiled by Murdock (1970). See `rawdata/kinbank/read_kinship.R` and `rawdata/murdock_kinship/read_murdock_kinship.R' for the steps used to prepare kinship data files.

### Social classification

Social classification data were drawn from Austkin. See `rawdata/austkin/` for scripts used to scrape this site.

### Color

Color data are drawn from the [`wcs`]( https://rdrr.io/github/jvosten/wcs/ )  package prepared by jvosten.

### Life forms

Life form data were manually transcribed from Appendix B of Brown, C. H. (1984). Language and living things: Uniformities in folk classification and naming. 

### Spatial demonstratives

Spatial demonstrative systems were drawn from the [repository]( https://github.com/cshnican/spatial_demonstratives ) released to accompany Chen, Futrell, Mahowald (2023), An information-theoretic approach to the typology of spatial demonstratives.  See `rawdata/nintemann_demonstratives/create_lang_csv.py` for the steps used to process the data.

### Other files

The folder also includes 

* `languoid.csv`: downloaded from Version 5.1 of [Glottolog]( https://doi.org/10.5281/zenodo.10804357 ) on 2025-04-10, and used when creating phylogenies for the phylogenetic regression analyses
* `phylogenies`: a folder for storing those phylogenies
* `missing_areas.csv`: a file manually created to specify areas of languages for which this information was missing from Glottolog


