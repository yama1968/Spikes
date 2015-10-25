

download.if.needed <- function(fname, 
                               url    = "http://staff.elena.aut.ac.nz/Paul-Cowpertwait/ts",
                               dir    = "./dat") {
    loc <- paste(dir, fname, sep = "/")
    
    if (file.exists(loc)) {
        loc
    } else {
        download.file(url = paste(url, fname, sep = "/"), destfile = loc)
        loc
    }
}

ql <- function(p, l) {
    apply(l, 2, function(x) quantile(x, probs = p))
}

