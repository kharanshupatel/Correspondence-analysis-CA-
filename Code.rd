---
title: "group2-Kharanshu Patel-CA"
author: "Kharanshu Patel"
date: "10/6/2018"
output: html_document
---

```{r setup, include=FALSE}
knitr::opts_chunk$set(echo = TRUE)

rm(list = ls())
graphics.off()

library(ExPosition)
library(corrplot)
library(ggplot2)
library(InPosition)
library(dplyr)
library(PTCA4CATA)
library(data4PCCAR)
library(classInt)
library(Hmisc)
library(psych)
library(TInPosition)
library(RColorBrewer)

dir4functions <- 'D:/acn4/r studio class/'
workingDir    <- 'D:/acn4/r studio class/'
file4functions <- 'InferencesMultinom4CA.R'

```
### Method: CA

Correspondence analysis (ca) is a generalized principal component analysis tailored for the analysis of qualitative data.The goal of correspondence analysis is to transform a data table into two sets of factor scores: One for the rows and one for the columns.

Rows and columns are displayed as points on the map whose coordinates are the factor scores and where the dimensions are called factors.

The factor scores of the rows and the columns have the same variance. Therefore, both rows and columns can be conveniently represented in one single map.

In correspondence analysis, a mass to each row and a weight to each column is assigned. The mass of each row reflects its importance in the sample. The mass of each row is the proportion of this row in the total of the table.
The weight of each column reflects its importance for discriminating between the variables. So the weight of a column reflects the information this columns provides to the identification of a given row.

### Dataset : Weekly Earnings by Race

The dataset contains information about the usual weekly earnings of people with various races and gender: White men, White women, Black men, Black women, Asian men, Asian women, Hispanic men, Hispanic women. These are the 8 rows. The 5 columns are 1st decile, 1st quartile, 2nd quartile, 3rd quartile and 9th decile. 

```{r data_set}

setwd('D://acn4/r studio class/')
WE <- read.csv('Weekly Earnings byRace(4).csv', row.names=1)

WE_data <- t(WE)
head(WE_data)
head(WE)

WE_dummy <- t(WE[(2:4), ])

WE_sup1 <- t(WE[1,]) 
WE_sup2 <- t(WE[6,]-WE[5,])

WE_col1 <- WE_dummy[,"1st quartile"]
WE_col2 <- WE_dummy[,"2nd quartile"] - WE_dummy[,"1st quartile"]
WE_col3 <- WE_dummy[,"3rd quartile"] - WE_dummy[,"2nd quartile"]
WE_col4 <- WE_data[,"Total people (in thousands)"] - WE_data[,"3rd quartile"]

WE_new <- cbind(WE_col1, WE_col2, WE_col3, WE_col4)
WE_new_t <- t(WE_new)

colnames(WE_new) = c("0-25%","25-50%","50-75%","75-100%")
colnames(WE_sup1) = c("0-10%")
colnames(WE_sup2) = c("90-100%")

WE_heat <- WE_new[ ,(1:3)]

```
## DESIGN

```{r design}

WE_DESIGN_gender <- rep(c("Men", "Women"),4)
WE_DESIGN_race <- rep(c("White", "Black", "Asian", "Hispanic"), each=2)
WE_DESIGN_quart <- rep(c("0-25%","25-50%","50-75%","75-100%"), each = 1)
t(WE_DESIGN_quart)

## COLOR

col4race2 = c("#00fcfe","#ff2ae3","#000969","#ab0205","#9800ff","#ff6205","#00688b","#ffe61c")

col4quart = c("greenyellow","green","green4","darkolivegreen")

```

### RESULTS

## COMPUTATIONS

# PCA
```{r PCA}

resPCA <- epPCA(DATA = WE_new,
                   scale = 'SS1',
                   graphs =  FALSE
                    )
eigs <- resPCA$ExPosition.Data$eigs

PCA.plot.fi <- prettyPlot(resPCA$ExPosition.Data$fi, col = col4race2, 
                           display_names = TRUE, 
                           dev.new=FALSE,
                           main = "Weekly Earnings Row Factor Scores",
                           x_axis = 1, y_axis = 2,
                           contributionCircles = TRUE,
                           display_points = TRUE, cex = 1.2,  
                           fg.col = "red",
                           text.cex = 0.7,
                           pos = 3,
                           axes = TRUE,
                           xlab = paste0("Component 1 Inertia: ",
                           round(resPCA$ExPosition.Data$t[1],3), "%"),
                           ylab = paste0("Component 2 Inertia: ",
                           round(resPCA$ExPosition.Data$t[2],3), "%")
)

PCAplot.fj <- prettyPlot(resPCA$ExPosition.Data$fj, col = col4quart, display_names = TRUE, dev.new=FALSE,
                           main = "Weekly Earnings Column Loadngs",
                           x_axis = 1, y_axis = 2,
                           contributionCircles = TRUE,
                           display_points = TRUE, cex = 1.5,  
                           fg.col = "red",
                           text.cex = 1,
                           pos = 2,
                           axes = TRUE,
                           xlab = paste0("Component 1 Inertia: ",
                           round(resPCA$ExPosition.Data$t[1],3), "%"),
                           ylab = paste0("Component 2 Inertia: ",
                           round(resPCA$ExPosition.Data$t[2],3), "%")
)
```
# CA 

```{r CA}

# symmetric
resCA.sym  <- epCA(WE_new, symmetric = TRUE)
resCA.sym_t <- epCA(WE_new_t, symmetric = TRUE)

# asymmetric
resCA.asym <- epCA(WE_new, symmetric = FALSE)
resCA.asym_t <- epCA(WE_new_t, symmetric = FALSE)


# Supplementary Variables
WE_new_sup1 <- supplementaryCols(SUP.DATA = WE_sup1, res = resCA.sym)
WE_new_sup2 <- supplementaryCols(SUP.DATA = WE_sup2, res = resCA.sym)

# Factor Scores
Fj.a <- resCA.asym$ExPosition.Data$fj
Fi   <- resCA.sym$ExPosition.Data$fi
Fj   <- resCA.sym$ExPosition.Data$fj

Fj.a_t <- resCA.asym_t$ExPosition.Data$fj
Fi_t <- resCA.sym_t$ExPosition.Data$fi
Fj_t   <- resCA.sym_t$ExPosition.Data$fj

```

# Inference battery 
```{r Inference Battery}
resCA.inf <- InPosition::epCA.inference.battery(DATA = WE_new,
                   DESIGN = WE_DESIGN_race,
                   graphs =  FALSE
                   )

resCA.inf_t <- InPosition::epCA.inference.battery(DATA = WE_new_t,
                   DESIGN = WE_DESIGN_quart,
                   graphs =  FALSE
                   )

```
## Group Analysis

# Bootstrap for Confidence Intervals:

```{r Bootstrap}

BootCube.i <- PTCA4CATA::Boot4Mean(Fi, 
                                 design = WE_DESIGN_race,
                                 niter = 100,
                                 suppressProgressBar = TRUE)

# Bootstrap ratios 
bootRatios.Gr <- boot.ratio.test(BootCube.i$BootCube)

# eigenvalues: MonteCarlo Approach ----
random.eigen <- data4PCCAR::monteCarlo.eigen(X = WE_new, nIter = 100)

# eigenvalues: Bootstrap approach
bootstrap.eigen <- data4PCCAR::boot.eigen(WE_new, nIter = 100)
```

# Constraints 

```{r Constraints}

# Constraints 
constraints.sym <- minmaxHelper(mat1 = Fi, mat2  = Fj)
constraints.asym <- minmaxHelper(mat1 = Fi, mat2  = Fj.a)
constraints.sup <- minmaxHelper(mat1 = rbind(Fj, WE_new_sup1$fjj), 
                                mat2  = rbind(Fj, WE_new_sup2$fjj) )


```
## PLOTTING

# Heat Map(Not Correlation)

```{r Heat Map}

heatMapIJ.WE <- makeggHeatMap4CT(WE_new,
colorAttributes = col4quart,
colorProducts = col4race2,
fontSize.x = 15
) + ggtitle('Heat Map')

print(heatMapIJ.WE)

# Heat Map after removing 4th column: 75-100%
heatMapIJ.WE2 <- makeggHeatMap4CT(WE_heat,
colorAttributes = col4quart,
colorProducts = col4race2,
fontSize.x = 15) + ggtitle('Heat Map excluding column 75-100%')

print(heatMapIJ.WE2)

```

## Scree Plot + Inference (Permutation Results)

```{r Scree Plot + Inference (Permutation Results)}

# Scree Plot with Permutation Test

PlotScree(ev = resCA.sym$ExPosition.Data$eigs, 
       p.ev = resCA.inf$Inference.Data$components$p.vals,
       title = 'Eigenvalues Inference',
       plotKaiser = TRUE
          )

```

# Base Map

```{r Base Map}
baseMap.i <- createFactorMap(Fi, constraints = constraints.sym,
                             col.points = col4race2,
                             col.labels = col4race2,
                             title = "Base Map for I")
print(baseMap.i$zeMap)

baseMap.j <- createFactorMap(Fj, constraints = constraints.sym,
                             col.points = col4quart,
                             col.labels = col4quart,
                             pch = 11,
                             title = "Base Map for J")
print(baseMap.j$zeMap)

```
# Varimax Rotations
```{r Varimax Rotations}

testVari    <- data4PCCAR::epVari(resCA.sym)

# Plot Varimax Rotations
# Labels

labels4Vari <- PTCA4CATA::createxyLabels.gen(1,2,
                                    lambda = testVari$rotated.eigs,
                                     tau = testVari$rotated.t)

# Plot the Rotated observations
# a graph for the observations

baseMap.i.rot <- PTCA4CATA::createFactorMap(testVari$rotated.I,
  col.points = col4race2,
  col.labels = col4race2,
  display.labels = TRUE,
  alpha.points = .5,
  title = 'Factor Scores Post Varimax'
)
Map.I.rot <- baseMap.i.rot$zeMap + labels4Vari
print(Map.I.rot)

baseMap.j.rot <- PTCA4CATA::createFactorMap(testVari$rotated.J,
                                  col.points   = col4quart,
                                   alpha.points =  .3,
                                   col.labels   = col4quart,
                                   title = 'Loadings Post Varimax')
# arrows
zeArrows.rot <- addArrows(testVari$rotated.J, color = col4quart)
# A graph for the J-set
Map.J.rot <- baseMap.j.rot$zeMap_background +
                     baseMap.j.rot$zeMap_dots +
                     baseMap.j.rot$zeMap_text +
                     zeArrows.rot + labels4Vari
print(Map.J.rot)
```

## Factor Scores : Symmetric

```{r Factor Scores : Symmetric Map}

# Symmetric map for I and J
symMap  <- createFactorMapIJ(Fi,Fj,
                             col.points.i = col4race2,
                             col.labels.i = col4race2,
                             col.points.j = col4quart,
                             col.labels.j = col4quart,
                             constraints = constraints.sym,
                             pch.i = 15, pch.j = 19,
                             alpha.labels.i = 0.8,
                             alpha.labels.j = 0.8,
                             alpha.axes = 0.2,
                             col.axes = "#333434",
                             col.background = "#fff3e1",
                             title = "Symmetric Factor Scores"
                             )

# Labels 
labels4CA <- PTCA4CATA::createxyLabels.gen(1,2, lambda = resCA.sym$ExPosition.Data$eigs, tau = resCA.sym$ExPosition.Data$t)

map.IJ.sym <- symMap$baseMap + symMap$I_labels + symMap$I_points +
  symMap$J_labels + symMap$J_points + labels4CA +
  theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank())

print(map.IJ.sym)
```

## Factor Scores : Asymmetric

```{r Factor Scores : Assymetric}
asymMap  <- createFactorMapIJ(Fi,Fj.a,
                              col.points.i = col4race2,
                              col.labels.i = col4race2,
                              col.points.j = col4quart,
                              col.labels.j = col4quart,
                              constraints = constraints.asym,
                              pch.i = 15, pch.j = 19,
                              alpha.labels.i = 0.8,
                              alpha.labels.j = 0.8,
                              alpha.axes = 0.2,
                              col.axes = "#333434",
                              col.background = "#f6e9e9",
                              title = "Asymmetric Factor Scores"
                              )

map.IJ.asym <- asymMap$baseMap + asymMap$I_labels + 
  asymMap$I_points + asymMap$J_labels + 
  asymMap$J_points + labels4CA + 
  theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank())

print(map.IJ.asym)

```
## Plot Supplemenatary variables
```{r Supplementary Variables}

# Supplementary variables: 1st decile, 9th decile
# Base Map
mapSup <- createFactorMapIJ(as.data.frame(WE_new_sup1$fjj), 
                            as.data.frame(WE_new_sup2$fjj),
                            col.points.i = "red1",
                            col.labels.i = 'red1',
                            col.points.j = 'red1',
                            col.labels.j = 'red1',
                            constraints = constraints.sup
)
map.sup <- mapSup$baseMap + mapSup$I_labels + mapSup$I_points + mapSup$J_labels + mapSup$J_points + ggtitle('Supplementary Variables')
print(map.sup)


# create an asymmetric map with a supplementary row
map.IJ.sup.asym <- asymMap$baseMap + asymMap$I_labels + 
  asymMap$I_points +
  asymMap$J_labels + asymMap$J_points + 
  mapSup$I_labels + mapSup$I_points +
  ggtitle('Asymmetric Map with Supplementary Elements') +
  labels4CA

print(map.IJ.sup.asym)

# Create a symmetric map with sup and correct constraints
map.IJ.sup.sym <- mapSup$baseMap + 
  symMap$I_labels + symMap$I_points +
  symMap$J_labels + symMap$J_points + 
  mapSup$I_labels + mapSup$I_points + 
  mapSup$J_labels + mapSup$J_points +
  ggtitle('Symmetric Map with Supplementary Elements') + 
  labels4CA

print(map.IJ.sup.sym)
```
## Contribution Bars

```{r Contribution Bars}

# I set
## Signed Contributions
signed.ctrI <- resCA.sym$ExPosition.Data$ci * sign(resCA.sym$ExPosition.Data$fi)

## Unsigned Contributions
unsigned.ctrI <- resCA.asym$ExPosition.Data$ci

# J set
## Signed Contributions
signed.ctrJ <- resCA.sym$ExPosition.Data$cj * sign(resCA.sym$ExPosition.Data$fj)

## Unsigned Contributions
unsigned.ctrJ <- resCA.asym$ExPosition.Data$cj

```

# I set : Signed Contributions # 1

```{r I set : Signed Contributions 1}
ctrI.s.1 <- PrettyBarPlot2(signed.ctrI[,1],
                         threshold = 1 / NROW(signed.ctrI),
                         font.size = 5,
                         color4bar = gplots::col2hex(col4race2), 
                         main = 'Weekly Earnings:  I set - Variable Contribution 1 (Signed)',
                         ylab = 'Contributions',
                         ylim = c(1.2*min(signed.ctrI), 1.2*max(signed.ctrI))
)

print(ctrI.s.1)
```

# I set : Signed Contributions # 2

```{r I set : Signed contributions 2}

ctrI.s.2 <- PrettyBarPlot2(signed.ctrI[,2],
                           threshold = 1 / NROW(signed.ctrI),
                           font.size = 5,
                           color4bar = gplots::col2hex(col4race2), 
                           main = 'Weekly Earnings: I set - Variable Contribution 2 (Signed)',
                           ylab = 'Contributions',
                           ylim = c(1.2*min(signed.ctrI), 1.2*max(signed.ctrI))
)

print(ctrI.s.2)

```


# J set : Signed Contributions # 1

```{r J set : Signed Contributions 1}

ctrJ.s.1 <- PrettyBarPlot2(signed.ctrJ[,1],
                         threshold = 1 / NROW(signed.ctrJ),
                         font.size = 5,
                         color4bar = gplots::col2hex(col4quart), 
                         main = 'Weekly Earnings: J set - Variable Contribution 1 (Signed)',
                         ylab = 'Contributions',
                         ylim = c(1.2*min(signed.ctrJ), 1.2*max(signed.ctrJ))
)

print(ctrJ.s.1)
```

# J set : Signed Contributions # 2

```{r J set : Signed contribution 2}

ctrJ.s.2 <- PrettyBarPlot2(signed.ctrJ[,2],
                           threshold = 1 / NROW(signed.ctrJ),
                           font.size = 5,
                           color4bar = gplots::col2hex(col4quart),
                           main = 'Weekly Earnings: J set - Variable Contribution 2 (Signed)',
                           ylab = 'Contributions',
                           ylim = c(1.2*min(signed.ctrJ), 1.2*max(signed.ctrJ))
)

print(ctrJ.s.2)

```

# I set : Unsigned Contributions # 1

```{r I set : Unsigned Contribution 1}

ctrI.u.1 <- PrettyBarPlot2(unsigned.ctrI[,1],
                         threshold = 1 / NROW(unsigned.ctrI),
                         font.size = 5,
                         horizontal = TRUE,
                         color4bar = gplots::col2hex(col4race2), 
                         main = 'Weekly Earnings: I-set - Variable Contribution 1 (Unsigned)',
                         ylab = 'Contributions',
                         ylim = c(-1,1)
)
print(ctrI.u.1)
```

# I set : Unsigned Contributions # 2

```{r I set : Unsigned contributions 2}
 
ctrI.u.2 <- PrettyBarPlot2(unsigned.ctrI[,2],
                           threshold = 1 / NROW(unsigned.ctrI),
                           font.size = 5,
                           color4bar = gplots::col2hex(col4race2),
                           main = 'WE_data Set: I set - Variable Contribution 2(Unsigned)',
                           ylab = 'Contributions',
                           ylim = c(-1,1)
)
print(ctrI.u.2)
```

# J set : Unsigned Contributions # 1

```{r J set : Unsigned Contribution 1}

ctrJ.u.1 <- PrettyBarPlot2(unsigned.ctrJ[,1],
                         threshold = 1 / NROW(unsigned.ctrJ),
                         font.size = 5,
                         color4bar = gplots::col2hex(col4quart), 
                         main = 'Weekly Earnings: J set - Variable Contribution 1 (Unsigned)',
                         ylab = 'Contributions',
                         ylim = c(-1,1)
)
print(ctrJ.u.1)
```

# J set : Unsigned Contributions # 2

```{r J set : Unsigned contributions 2}
 
ctrJ.u.2 <- PrettyBarPlot2(unsigned.ctrJ[,2],
                           threshold = 1 / NROW(unsigned.ctrJ),
                           font.size = 5,
                           color4bar = gplots::col2hex(col4quart),
                           main = 'Weekly Earnings: J set - Variable Contribution 2(Unsigned)',
                           ylab = 'Contributions',
                           ylim = c(-1,1)
)
print(ctrJ.u.2)
```

## Bootstrap Ratio Bars

```{r Bootstrap Ratios}

BR.i <- resCA.inf$Inference.Data$fj.boots$tests$boot.ratios
BR.j <- resCA.inf_t$Inference.Data$fj.boots$tests$boot.ratios

## J-set Dimension 1
laDim = 1
map.BR1.j <- PrettyBarPlot2(BR.i[,laDim],
                        threshold = 2,
                        font.size = 5,
                   color4bar = gplots::col2hex(col4quart), 
                   main = paste0(
                     'Weekly Earnings: J-set Bootstrap ratio ',laDim),
                  ylab = 'Bootstrap ratios'
                  #ylim = c(1.2*min(BR[,laDim]), 1.2*max(BR[,laDim]))
)
print(map.BR1.j)

## J-set Dimension 2
laDim = 2
map.BR2.j <- PrettyBarPlot2(BR.i[,laDim],
                            threshold = 2,
                            font.size = 5,
                            color4bar = gplots::col2hex(col4quart),
                            main = paste0(
                              'Weekly Earnings: J-set Bootstrap ratio ',laDim),
                ylab = 'Bootstrap ratios'
)
print(map.BR2.j)

## I-set Dimension 1
laDim = 1
map.BR1.i <- PrettyBarPlot2(BR.j[,laDim],
                        threshold = 2,
                        font.size = 5,
                   color4bar = gplots::col2hex(col4race2), 
                   main = paste0(
                     'Weekly Earnings: I-set Bootstrap ratio ',laDim),
                  ylab = 'Bootstrap ratios'
                  #ylim = c(1.2*min(BR[,laDim]), 1.2*max(BR[,laDim]))
)
print(map.BR1.i)

## I-set Dimension 2
laDim = 2
map.BR2.i <- PrettyBarPlot2(BR.j[,laDim],
                            threshold = 2,
                            font.size = 5,
                            color4bar = gplots::col2hex(col4race2),
                            main = paste0(
                              'Weekly Earnings: I-set Bootstrap ratio ',laDim),
                ylab = 'Bootstrap ratios'
)
print(map.BR2.i)

```
