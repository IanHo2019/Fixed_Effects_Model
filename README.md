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

In the dataset cleaning and construction process,
  1. Observations are dropped if information on any of the four country-level variables is missing.
  1. After step 1, if a country has only one observation, then it is dropped as well.
  1. For better reporting in figures, I change the unit of `gdppc`, `export`, and `import` to billion US dollars and change the unit of `labor` to thousand.
  1. I generate a new variable, named `trade`, by summation of `export` and `import`.
  1. Finally, `gdppc`, `labor`, and `trade` are log transformed.

The complete coding can be found here.

## Three Kingdoms! `xtreg`, `areg`, and `reghdfe`!
The complete coding can be found here.
