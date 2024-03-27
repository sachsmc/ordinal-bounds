theta_bounds_K_three_noncomp <- function (p00_0 = NULL, p10_0 = NULL, p01_0 = NULL, p11_0 = NULL, 
    p02_0 = NULL, p12_0 = NULL, p00_1 = NULL, p10_1 = NULL, p01_1 = NULL, 
    p11_1 = NULL, p02_1 = NULL, p12_1 = NULL) 
{
    lb <- pmax(-p00_0 - p10_0 - 2 * p01_0 - 2 * p11_0 - 2 * p02_0 + 
        p00_1 + p10_1 + p01_1 + 2 * p11_1, -p00_0 - p10_0 - p01_0 - 
        p11_0 + p00_1 + p01_1, -p00_0 - p10_0 - p01_0 - p11_0 - 
        p02_0 + p00_1 + p10_1 + p01_1 + p11_1, -p10_0 - p01_0 - 
        p11_0 - p02_0 + p01_1 + p11_1, p00_0 - p10_0 - p01_0 - 
        p11_0 - p00_1 - p10_1 + p01_1, -p10_0 - p01_0 - p11_0 + 
        p01_1, p00_0 + p10_0 + p01_0 + p11_0 - p00_1 - p10_1 - 
        p01_1 - p11_1 - p02_1, p00_0 + p01_0 - p00_1 - p10_1 - 
        p01_1 - p11_1, p01_0 - p10_1 - p01_1 - p11_1, p00_0 - 
        p00_1 - p10_1, p00_0 + p10_0 - p00_1 - p10_1 - p01_1 - 
        p02_1, 0, -p01_0 - p11_0 - p02_0 + p11_1, p11_0 - p01_1 - 
        p11_1 - p02_1, p00_0 + p10_0 + p01_0 + 2 * p11_0 - p00_1 - 
        p10_1 - 2 * p01_1 - 2 * p11_1 - 2 * p02_1, p01_0 + p11_0 - 
        p10_1 - p01_1 - p11_1 - p02_1, -p00_0 - p10_0 + p01_0 + 
        p00_1 - p10_1 - p01_1 - p11_1, -p00_0 - p10_0 + p00_1, 
        -p00_0 - p10_0 - p01_0 - p02_0 + p00_1 + p10_1)
    ub <- pmin(1 - p10_0 - p02_0, 2 - p10_0 - p01_0 - p02_0 - 
        p00_1 - p10_1 - p11_1 - p02_1, 1 + p00_0 - p10_0 + p11_0 - 
        p11_1, 2 - p00_0 - p10_0 - p11_0 - 2 * p02_0 - p01_1, 
        2 - p01_0 - p00_1 - p10_1 - p11_1 - 2 * p02_1, 1 + p00_0 + 
            p11_0 - p10_1 - p11_1 - p02_1, 1 - p10_0 - p11_0 - 
            p02_0 + p00_1 + p11_1, 2 - p00_0 - p10_0 - p11_0 - 
            p02_0 - p10_1 - p01_1 - p02_1, 1 - p10_1 - p02_1, 
        1 - p11_0 + p00_1 - p10_1 + p11_1)
    if (any(ub < lb)) {
        warning("Invalid bounds! Data probably does not satisfy the assumptions in the DAG!")
    }
    data.frame(lower = lb, upper = ub)
}



theta_bounds_K_three_noncomp_nodefiers <- function (p00_0 = NULL, p10_0 = NULL, p01_0 = NULL, p11_0 = NULL, 
    p02_0 = NULL, p12_0 = NULL, p00_1 = NULL, p10_1 = NULL, p01_1 = NULL, 
    p11_1 = NULL, p02_1 = NULL, p12_1 = NULL) 
{
    lb <- pmax(0, p00_0 + p10_0 - p00_1 - p10_1, p00_0 + p10_0 + 
        p01_0 + p11_0 - p00_1 - p10_1 - p01_1 - p11_1)
    ub <- pmin(1 + p00_0 + p11_0 - p00_1 - p10_1 - p11_1 - p02_1, 
        1 - p10_0 - p02_0, 1 - p10_1 - p02_1)
    if (any(ub < lb)) {
        warning("Invalid bounds! Data probably does not satisfy the assumptions in the DAG!")
    }
    data.frame(lower = lb, upper = ub)
}



