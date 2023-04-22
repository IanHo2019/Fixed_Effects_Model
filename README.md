# Fixed Effects Model
In this repository, I will show some basic applications of fixed effects (FE) models to a real world data ([World Development Indicators](https://databank.worldbank.org/source/world-development-indicators)) and some post-estimation hypothesis testing in Stata. The focus will be on the use of three Stata commands:
  * `xtreg` with the `fe` option;
  * `areg` with the `absorb( )` option;
  * `reghdfe` with the `absorb( )` option.

Before the start, I want to show my appreciation to Professor [Jack Porter](https://www.ssc.wisc.edu/~jrporter/), Professor [Mikkel Sølvsten](https://sites.google.com/site/mikkelsoelvsten/), and Professor [Bruce Hansen](https://www.ssc.wisc.edu/~bhansen/); without their lectures, I couldn't have a good understanding of fixed effects models and other related topics.


## Basics of FE Models
With probability one, the fixed effects model is the most popular model in panel data methods. The simplest form of this model is
$$Y_{it} = X_{it}'\beta + u_i + \varepsilon_{it}$$
where
  * $Y_{it}$ is the dependent variable.
  * $X_{it}$ is a $k \times 1$ vector of regressors.
  * $\beta$ is the coefficient of interest.
  * $u_i$ is a **time-invariant unobserved missing variable**, such as an individual's birth year. $u_i$ is expected to be correlated with the regressors $X_{it}$.
  * $\varepsilon_{it}$ is an idiosyncratic error term.
Due to the presence of $u_i$, it's impossible to identify $\beta$ under a simple regular assumption such as $E(X_{it} \varepsilon_{it}) = 0$. This is the reason why FE models were born. By applying the within transformation to the equation above, we can eliminate $u_i$ and then construct an unbiased estimator for $\beta$ by generalized least squares (GLS).

The key difference between FE models and random effects (RE) models is
  * In a FE model, we don't impose any assumptions on $u_i$.
  * In a RE model, we make three assumptions on $u_i$:
    * $E(u_i|\mathbf{X}_i) = 0$;
    * $E(u_i^2|\mathbf{X}_i) = \sigma_u^2$;
    * $E(u_i \varepsilon|\mathbf{X}_i) = 0$, where $\mathbf{X}_i$ is a $T_i \times k$ matrix of $X_{it}'$ and $T_i$ is the number of periods observed for individual $i$.


## Data
The data I use are from the freely available [World Development Indicators](https://databank.worldbank.org/source/world-development-indicators) (WDI) provided by The World Bank. My data selection is:
  * **Country:** All 217 countries. Note that the WDI also constains data for regions (such as East Asia & Pacific); if you include them in your dataset by mistake, then you have to drop them manually or with the help of some statistical softwares.
  * **Series:** Four variables, including
    * GDP per capita (constant 2015 US$)
    * Exports of goods and services (constant 2015 US$)
    * Imports of goods and services (constant 2015 US$)
    * Labor force, total
  * **Time:** Years from 2000 to 2021.

**Note:** The default format of WDI data file is not (directly) suitable for panel data analysis. I recommend to customize the layout of data format on the WDI webpage before downloading the data; otherwise, you may spend some time reshaping the dataset to a panel. A good guideline for downloading WDI is in slide 21 of Professor Oscar Torres-Reyna's "*Finding Data*" ([here](https://www.princeton.edu/~otorres/FindingData101.pdf)).

In the dataset cleaning and construction process,
  1. Observations are dropped if information on any of the four country-level variables is missing.
  1. After step 1, if a country has only one observation, then it is dropped as well.
  1. For better reporting in figures, I change the unit of `gdppc`, `export`, and `import` to billion US dollars and change the unit of `labor` to thousand.
  1. I generate a new variable, named `trade`, by summation of `export` and `import`.
  1. Finally, `gdppc`, `labor`, and `trade` are log transformed.

The complete coding can be found [here](./Dataset_Construction.do).

## [Three Kingdoms](https://en.wikipedia.org/wiki/Three_Kingdoms)! `xtreg`, `areg`, and `reghdfe`!
There are four important differences among these three commands:
  * Vanriance-covariance matrix estimation is different; in particular, the degree-of-freedom adjustments are different.
  * $R^2$'s are calculated in different ways.
  * The options for adding fixed effects are different.
  * Computation speeds are different. As [Sergio Correia](http://scorreia.com/) (the author of the `reghdfe` package) claimed, even with only one level of fixed effects, `reghdfe` is faster than `xtreg` and `areg`. I first tried the `reghdfe` package in 2021, when I was working on my graduation dissertation for Master degree. My comment is: Good!

The complete coding for running FE models can be found [here](./Fixed_Effects_Models.do).
