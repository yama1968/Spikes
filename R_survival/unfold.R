
unfold <- function (data, time, event, cov, cov.names = paste("covariate",
                                                              ".", 1:ncovs, sep = ""), suffix = ".time", cov.times = 0:ncov,
                    common.times = TRUE, lag = 0, ...) {
  vlag <- function(x, lag) c(rep(NA, lag), x[1:(length(x) -
                                                  lag)])
  xlag <- function(x, lag) apply(as.matrix(x), 2, vlag, lag = lag)
  all.cov <- unlist(cov)
  if (!is.numeric(all.cov))
    all.cov <- which(is.element(names(data), all.cov))
  if (!is.list(cov))
    cov <- list(cov)
  ncovs <- length(cov)
  nrow <- nrow(data)
  ncol <- ncol(data)
  ncov <- length(cov[[1]])
  nobs <- nrow * ncov
  if (length(unique(c(sapply(cov, length), length(cov.times) -
                      1))) > 1)
    stop(paste("all elements of cov must be of the same length and \n",
               "cov.times must have one more entry than each element of cov."))
  var.names <- names(data)
  subjects <- rownames(data)
  omit.cols <- if (!common.times)
    c(all.cov, cov.times)
  else all.cov
  keep.cols <- (1:ncol)[-omit.cols]
  factors <- names(data)[keep.cols][sapply(data[keep.cols],
                                           is.factor)]
  levels <- lapply(data[factors], levels)
  first.covs <- sapply(cov, function(x) x[1])
  factors.covs <- which(sapply(data[first.covs], is.factor))
  levels.covs <- lapply(data[names(factors.covs)], levels)
  nkeep <- length(keep.cols)
  if (is.numeric(event))
    event <- var.names[event]
  events <- sort(unique(data[[event]]))
  if (length(events) > 2 || (!is.numeric(events) && !is.logical(events)))
    stop("event indicator must have values {0, 1}, {1, 2} or {FALSE, TRUE}")
  if (!(all(events == 0:1) || all(events == c(FALSE, TRUE)))) {
    if (all(events = 1:2))
      data[[event]] <- data[[event]] - 1
    else stop("event indicator must have values {0, 1}, {1, 2} or {FALSE, TRUE}")
  }
  times <- if (common.times)
    matrix(cov.times, nrow, ncov + 1, byrow = TRUE)
  else data[, cov.times]
  new.data <- matrix(Inf, nobs, 3 + ncovs + nkeep)
  rownames <- rep("", nobs)
  colnames(new.data) <- c("start", "stop", paste(event, suffix,
                                                 sep = ""), var.names[-omit.cols], cov.names)
  end.row <- 0
  data <- as.matrix(as.data.frame(lapply(data, as.numeric)))
  for (i in 1:nrow) {
    start.row <- end.row + 1
    end.row <- end.row + ncov
    start <- times[i, 1:ncov]
    stop <- times[i, 2:(ncov + 1)]
    event.time <- ifelse(stop == data[i, time] & data[i,
                                                      event] == 1, 1, 0)
    keep <- matrix(data[i, -omit.cols], ncov, nkeep, byrow = TRUE)
    select <- apply(matrix(!is.na(data[i, all.cov]), ncol = ncovs),
                    1, all)
    rows <- start.row:end.row
    cov.mat <- xlag(matrix(data[i, all.cov], nrow = length(rows)),
                    lag)
    new.data[rows[select], ] <- cbind(start, stop, event.time,
                                      keep, cov.mat)[select, ]
    rownames[rows] <- paste(subjects[i], ".", seq(along = rows),
                            sep = "")
  }
  row.names(new.data) <- rownames
  new.data <- as.data.frame(new.data[new.data[, 1] != Inf &
                                       apply(as.matrix(!is.na(new.data[, cov.names])), 1, all),
                                     ])
  for (fac in factors) {
    new.data[[fac]] <- factor(levels[[fac]][new.data[[fac]]])
  }
  fcv <- 0
  for (cv in factors.covs) {
    fcv <- fcv + 1
    new.data[[cov.names[cv]]] <- factor(levels.covs[[fcv]][new.data[[cov.names[cv]]]])
  }
  new.data
}