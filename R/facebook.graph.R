#

install.packages("Rfacebook")


library(Rfacebook)
fb_oauth <- fbOAuth(app_id = "682552538567159",
                 app_secret = my.secret,
                 extended_permissions = T)

save(fb_oauth, file="fb_oauth")

me <- getUsers("me",token=fb_oauth)

my_likes <- getLikes(user="me", token=fb_oauth)

# Get friend info:
my.friends <- getFriends(fb_oauth, simplify=F)

# Get friend network in two formats, matrix and edge list:
fb.net.mat <- getNetwork(oauth, format="adj.matrix")+0 # bool,+0 to get numeric
fb.net.el  <- as.data.frame(getNetwork(oauth, format = "edgelist"))
