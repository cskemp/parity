## Symmetry in category systems across languages

This repository contains code and data for Kemp, Symmetry in category systems across languages 

## Folder structure

#### analysis

Includes two notebooks that run the main analyses and create figures for the manuscript

#### data

Includes data files for domains considered in the paper

## Installing R Libraries  
 
From within R, run 
 
`> renv::restore()` 
 
to install packages used by the code in this repository.

The code uses one package (`jvosten/wcs`) that was downloaded from GitHub and is not available on CRAN. `renv::restore()` should pick this up, but if not it can be directly installed using `remotes::install_github("jvosten/wcs")`




