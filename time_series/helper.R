

download.if.needed <- function(fname, 
                               url    = "http://staff.elena.aut.ac.nz/Paul-Cowpertwait/ts",
                               dir    = "dat") {
    loc <- paste(dir, fname, sep = "/")
    
    if (exists(loc)) {
        loc
    } else {
        download.file(url = paste(url, fname, sep = "/"), destfile = loc)
        loc
    }
}