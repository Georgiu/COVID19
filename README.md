# cluster-analysis-of-data-on-the-dynamics-of-the-covid-19-epidemic-with-R
R project for cluster analysis of data on the dynamics of the covid-19 epidemic with k-mean and hierarchical clustering usind DTW-distances.

# Data
You can download data via csv by the [link](https://ourworldindata.org/explorers/coronavirus-data-explorer?zoomToSelection=true&time=2020-03-04..latest&facet=none&pickerSort=asc&pickerMetric=location&hideControls=true&Metric=Confirmed+cases&Interval=New+per+day&Relative+to+Population=false&Color+by+test+positivity=false&country=~UKR) with needed countries.
# Data preparation
  - For data smoothing was used [Nadaraya–Watson estimator](https://en.wikipedia.org/wiki/Kernel_regression)
  - For data scaling was used [min-max method](https://en.wikipedia.org/wiki/Feature_scaling)\

After preparation data looks like:\
![example](https://github.com/Georgiu/COVID19/data_preparation.png)

# Distances
For distances between countries was used [Dynamic Time Warping (DTW)](https://cran.r-project.org/web/packages/dtw/vignettes/dtw.pdf) approach. It's better approach for time series comparing to classical methods because it's capable of finding disease peaks that can be shifted relative to each other and calculating distance between them not between relative pairs Xi and Yi as classical methods do. So it gives us more accurate distances between countries.

Example of calculated DTW-distances between two time series (countries):
![example](https://github.com/Georgiu/COVID19/DTW_example.png)

# Clustering
  - Multidimensional scaling + knn
  - Hierarchical clustering with finding optimal linkage method and optimal number of clusters using [gap statistics](https://hastie.su.domains/Papers/gap.pdf)
# Comparison of results
Comparison between used clustering methods (mds + knn and hclust) using [Rand Index and cintigency table](https://en.wikipedia.org/wiki/Rand_index#:~:text=The%20Rand%20index%20or%20Rand,is%20the%20adjusted%20Rand%20index.).

# Results Interpretation
Example of hierarchical clustering results researching 25 European countries (used service www.mapchart.net/europe.html):
![results example](https://github.com/Georgiu/COVID19/hclust.jpg)
