
<!-- README.md is generated from README.Rmd. Please edit that file -->

# Sharp symbolic nonparametric bounds for measures of benefit in observational and imperfect randomized studies with ordinal outcomes – Code

### Authors: Erin E Gabriel, Michael C Sachs, Andreas Kryger Jensen

This repository contains R functions to compute nonparametric bounds on
measures of benefit for ordinal outcomes in settings with noncompliance.
The bounds expressions are complicated but the functions are easy to
use. They take as inputs the conditional probabilities of the form

$$
p(X = x, Y = y | Z = z)
$$

with $y \in (0, 1, \ldots, K - 1), x \in (0, 1),$ and $z \in (0, 1)$. We
denote these in the code as `pxy_z`

We provide bounds functions for $K = 3, 4, 5, 6, 7$ in the instrumental
variable setting with and without the no defiers assumption for

$$
\psi = p(Y_i(1) \geq Y_i(0)), \mbox{ the probability of no harm,}
$$

$$
\theta = p(Y_i(1) > Y_i(0)), \mbox{ the probability of benefit, and}
$$

$$
\phi = p(Y_i(1) > Y_i(0)) - p(Y_i(1) < Y_i(0)), \mbox{ the relative treatment effect}.
$$

See the manuscript <https://arxiv.org/abs/2305.10555> for more details.

## Example usage

Generate some true probabilities and example data from that distribution

``` r
source("generate-data.R")
exdata <- generate_dataset(n = 150, K = 4, scenario = "noncompliance")
exdata$trueP
#> $p00_0
#> [1] 0.03377209
#> 
#> $p01_0
#> [1] 0.05168947
#> 
#> $p02_0
#> [1] 0.07230853
#> 
#> $p03_0
#> [1] 0.1315845
#> 
#> $p10_0
#> [1] 0.1499474
#> 
#> $p11_0
#> [1] 0.1655966
#> 
#> $p12_0
#> [1] 0.1813162
#> 
#> $p13_0
#> [1] 0.2137852
#> 
#> $p00_1
#> [1] 0.2488561
#> 
#> $p01_1
#> [1] 0.1953648
#> 
#> $p02_1
#> [1] 0.1878757
#> 
#> $p03_1
#> [1] 0.2182795
#> 
#> $p10_1
#> [1] 0.02013578
#> 
#> $p11_1
#> [1] 0.02972606
#> 
#> $p12_1
#> [1] 0.03931386
#> 
#> $p13_1
#> [1] 0.06046035
```

Find the corresponding bounds functions and source them.

``` r
source("bounds-source/phi-K-four.R")
do.call(phi_bounds_K_four_noncomp, exdata$trueP)
#>        lower     upper
#> 1 -0.4818838 0.6317731


source("bounds-source/theta-K-four.R")
do.call(theta_bounds_K_four_noncomp_nodefiers, exdata$trueP)
#>   lower     upper
#> 1     0 0.6806982
```

View the source and arguments

``` r
theta_bounds_K_four_noncomp_nodefiers
#> function (p00_0 = NULL, p10_0 = NULL, p01_0 = NULL, p11_0 = NULL, 
#>     p02_0 = NULL, p12_0 = NULL, p03_0 = NULL, p13_0 = NULL, p00_1 = NULL, 
#>     p10_1 = NULL, p01_1 = NULL, p11_1 = NULL, p02_1 = NULL, p12_1 = NULL, 
#>     p03_1 = NULL, p13_1 = NULL) 
#> {
#>     lb <- pmax(p00_0 + p10_0 + p01_0 + p11_0 - p00_1 - p10_1 - 
#>         p01_1 - p11_1, p00_0 + p10_0 - p00_1 - p10_1, 0, p00_0 + 
#>         p10_0 + p01_0 + p11_0 + p02_0 + p12_0 - p00_1 - p10_1 - 
#>         p01_1 - p11_1 - p02_1 - p12_1)
#>     ub <- pmin(1 + p00_0 + p11_0 - p00_1 - p10_1 - p11_1 - p03_1, 
#>         1 - p10_0 - p03_0, 1 + p00_0 + p01_0 + p11_0 + p12_0 - 
#>             p00_1 - p10_1 - p01_1 - p11_1 - p12_1 - p03_1, 1 - 
#>             p10_1 - p03_1)
#>     if (any(ub < lb)) {
#>         warning("Invalid bounds! Data probably does not satisfy the assumptions in the DAG!")
#>     }
#>     data.frame(lower = lb, upper = ub)
#> }
#> <bytecode: 0x000001fff4d18a00>
formals(theta_bounds_K_four_noncomp_nodefiers)
#> $p00_0
#> NULL
#> 
#> $p10_0
#> NULL
#> 
#> $p01_0
#> NULL
#> 
#> $p11_0
#> NULL
#> 
#> $p02_0
#> NULL
#> 
#> $p12_0
#> NULL
#> 
#> $p03_0
#> NULL
#> 
#> $p13_0
#> NULL
#> 
#> $p00_1
#> NULL
#> 
#> $p10_1
#> NULL
#> 
#> $p01_1
#> NULL
#> 
#> $p11_1
#> NULL
#> 
#> $p02_1
#> NULL
#> 
#> $p12_1
#> NULL
#> 
#> $p03_1
#> NULL
#> 
#> $p13_1
#> NULL
```
