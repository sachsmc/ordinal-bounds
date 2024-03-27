
rmvunif <- function(n, K) {
  y <- matrix(rexp(n * K), ncol = K)
  y / rowSums(y)
}


generate_dataset <- function(n = 200, K = 5, 
                             scenario = c("randomized", 
                             "confounded", "noncompliance", "noncompliance monotone"), 
                             bb = NULL, pZ = NULL, theta = NULL) {
  
  scenario <- match.arg(scenario)
  
  if(is.null(pZ)) {
    pZ <- runif(1, .2, .8)
  }
  Z <- rbinom(n, 1, prob = pZ)
  
  if(is.null(theta)) {
    theta <- rnorm(1, 0, 2)
  }
  
  if(scenario == "randomized") {  ## probabilities of the form p(Y | X) = py_x
    
    X <- Z
    Ycont <- rnorm(n, mean = X * theta, sd = 1)
    cuts <- qnorm(seq(0, 1, length.out = K + 1))
    Y <- as.numeric(cut(Ycont, breaks = cuts))
    
    dataset <- data.frame(Z, X, Y)
    
    pY.0 <- diff(seq(0, 1, length.out = K + 1))
    pY.1 <- diff(pnorm(cuts, mean = theta))
    trueP <- as.list(c(pY.0, pY.1))
    names(trueP) <- sprintf("p%s_%s", rep(0:(K-1), 2), rep(0:1, each = K))
    
    return(list(dataset = dataset, 
         trueP = trueP))
    
    
  } else if(scenario == "confounded") { ## probs of the form p(X, Y) = pxy_
    
    U <- rnorm(n)
    aa <- rnorm(2)
    X <- rbinom(n, 1, prob = pnorm(aa[1] + aa[2] * U))
    
    if(!is.null(bb)) {
      b <- bb[1:2]
    } else {
      b <- rnorm(2, 0, 2)
    }
    Ycont <- rnorm(n, mean = X * theta + b[1] * U + b[2] * U * X, sd = 1)
    cuts <- qnorm(seq(0, 1, length.out = K + 1))
    Y <- as.numeric(cut(Ycont, breaks = cuts))
    
    dataset <- data.frame(Z = X, X, Y)
    
    pY0 <- diff(sapply(cuts, \(incuts) {integrate(\(u) (1 - pnorm(aa[1] + aa[2] * u)) * pnorm(incuts, mean = b[1] * u) * dnorm(u), 
                     lower = -Inf, upper = Inf)$value }))
    pY1 <- diff(sapply(cuts, \(incuts) {integrate(\(u) (pnorm(aa[1] + aa[2] * u)) * 
                                                    pnorm(incuts, mean = theta + b[1] * u + b[2] * u) * dnorm(u), 
                                                  lower = -Inf, upper = Inf)$value }))
    
    trueP <- as.list(c(pY0, pY1))
    names(trueP) <- sprintf("p%s%s_", rep(0:1, each = K), rep(0:(K-1), 2))
    
    list(dataset = dataset, 
         trueP = trueP)
    
    
  } else if(scenario == "noncompliance") { ## probs of the form p(X, Y | Z) = pxy_z
    
    U <- rnorm(n)
    
    if(!is.null(bb)) {
      b <- bb[1:2]
    } else {
      b <- rnorm(2, 0, 2)
    }
    cutats <- sort(c(0, 1, runif(3)))
    threshU <-qnorm(cutats)
    
    cutU <- as.numeric(cut(U, threshU))
    probU <- diff(cutats)
    
    Ztmp <- cbind(0, 1, Z, 1 - Z)
    X <- Ztmp[cbind(1:n, cutU)]
    
    Ycont <- rnorm(n, mean = X * theta + b[1] * U + b[2] * U * X, sd = 1)
    cuts <- qnorm(seq(0, 1, length.out = K + 1))
    Y <- as.numeric(cut(Ycont, breaks = cuts))
    
    dataset <- data.frame(Z, X, Y)
    
    pYX1.0 <- sapply(cuts, \(incuts) {
      integrate(\(u) {
        pnorm(incuts, mean = theta + b[1] * u + b[2] * u) * 
      (1.0 * (u >= threshU[2] & u <= threshU[3]) + 1.0 * (u >= threshU[4])) *
      dnorm(u) 
      }, -Inf, Inf)$value
    }) |> diff()
    pYX0.0 <- sapply(cuts, \(incuts) {
      integrate(\(u) {
        pnorm(incuts, mean = b[1] * u) * 
          (1.0 * (u <= threshU[2]) + 1.0 * (u >= threshU[3] & u <= threshU[4])) *
          dnorm(u) 
      }, -Inf, Inf)$value
    }) |> diff()
    pYX1.1 <- sapply(cuts, \(incuts) {
      integrate(\(u) {
        pnorm(incuts, mean = theta + b[1] * u + b[2] * u) * 
          (1.0 * (u >= threshU[2] & u <= threshU[3]) + 1.0 * (u >= threshU[3] & u <= threshU[4])) *
          dnorm(u) 
      }, -Inf, Inf)$value
    }) |> diff()
    pYX0.1 <- sapply(cuts, \(incuts) {
      integrate(\(u) {
        pnorm(incuts, mean = b[1] * u) * 
          (1.0 * (u <= threshU[2]) + 1.0 * (u >= threshU[4])) *
          dnorm(u) 
      }, -Inf, Inf)$value
    }) |> diff()
    
    
    trueP <- as.list(c(pYX0.0, pYX1.0, pYX0.1, pYX1.1))
    names(trueP) <- sprintf("p%s%s_%s", 
                            c(rep(0, K), rep(1, K), rep(0, K), rep(1, K)), 
                            rep(0:(K-1), 4), 
                            rep(0:1, each = 2*K))
    
    list(dataset = dataset, 
         trueP = trueP)
    
    
  } else if(scenario == "noncompliance monotone") { ## probs of the form p(X, Y | Z) = pxy_z
    
    U <- rnorm(n)
    
    if(!is.null(bb)) {
      b <- bb[1:2]
    } else {
      b <- rnorm(2, 0, 2)
    }
    cutats <- sort(c(0, 1, runif(2)))
    threshU <-qnorm(cutats)
    
    cutU <- as.numeric(cut(U, threshU))
    probU <- diff(cutats)
    
    Ztmp <- cbind(0, 1, Z)
    X <- Ztmp[cbind(1:n, cutU)]
    
    Ycont <- rnorm(n, mean = X * theta + b[1] * U + b[2] * U * X, sd = 1)
    cuts <- qnorm(seq(0, 1, length.out = K + 1))
    Y <- as.numeric(cut(Ycont, breaks = cuts))
    
    dataset <- data.frame(Z, X, Y)
    
    pYX1.0 <- sapply(cuts, \(incuts) {
      integrate(\(u) {
        pnorm(incuts, mean = theta + b[1] * u + b[2] * u) * 
          (1.0 * (u > threshU[2] & u <= threshU[3])) *
          dnorm(u) 
      }, -Inf, Inf)$value
    }) |> diff()
    pYX0.0 <- sapply(cuts, \(incuts) {
      integrate(\(u) {
        pnorm(incuts, mean = b[1] * u) * 
          (1.0 * (u <= threshU[2]) + 1.0 * (u > threshU[3])) *
          dnorm(u) 
      }, -Inf, Inf)$value
    }) |> diff()
    pYX1.1 <- sapply(cuts, \(incuts) {
      integrate(\(u) {
        pnorm(incuts, mean = theta + b[1] * u + b[2] * u) * 
          (1.0 * (u >= threshU[2] & u <= threshU[3]) + 1.0 * (u >= threshU[3])) *
          dnorm(u) 
      }, -Inf, Inf)$value
    }) |> diff()
    pYX0.1 <- sapply(cuts, \(incuts) {
      integrate(\(u) {
        pnorm(incuts, mean = b[1] * u) * 
          (1.0 * (u <= threshU[2])) *
          dnorm(u) 
      }, -Inf, Inf)$value
    }) |> diff()
    
    
    trueP <- as.list(c(pYX0.0 / (sum(unlist(pYX0.0) + unlist(pYX1.0))), 
                       pYX1.0 / (sum(unlist(pYX0.0) + unlist(pYX1.0))), 
                       pYX0.1 / (sum(unlist(pYX0.1) + unlist(pYX1.1))), 
                       pYX1.1 / (sum(unlist(pYX0.1) + unlist(pYX1.1)))))
    names(trueP) <- sprintf("p%s%s_%s", 
                            c(rep(0, K), rep(1, K), rep(0, K), rep(1, K)), 
                            rep(0:(K-1), 4), 
                            rep(0:1, each = 2*K))
    
    list(dataset = dataset, 
         trueP = trueP)
    
    
  }
  
  
  
}
