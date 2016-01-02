

library(rmongodb)

# mongoimport --db rmongodb --collection zips < github/Spikes/mongodb/zips.json 

mongo <- mongo.create()
mongo

if(mongo.is.connected(mongo) == TRUE) {
    mongo.get.databases(mongo)
}
if(mongo.is.connected(mongo) == TRUE) {
    db <- "rmongodb"
    mongo.get.database.collections(mongo, db)
}
mongo.is.connected(mongo)

ns <- "database.collection"
json <- '{"a":1, "b":2, "c": {"d":3, "e":4}}'
bson <- mongo.bson.from.JSON(json)
mongo.insert(mongo, ns, bson)

mongo.drop.database(mongo, db)
mongo.get.database.collections(mongo, db)

# mongoimport --db rmongodb --collection zips < github/Spikes/mongodb/zips.json 

colls <- mongo.get.database.collections(mongo, db)
mongo.find.one(mongo, colls[[1]])
coll <- colls[[1]]

cityone <- mongo.find.one(mongo, coll, '{"city":"COLORADO CITY"}')
print( cityone )
mongo.bson.to.list(cityone)


# insert data
a <- mongo.bson.from.JSON( '{"ident":"a", "name":"Markus", "age":33}' )
b <- mongo.bson.from.JSON( '{"ident":"b", "name":"MongoSoup", "age":1}' )
c <- mongo.bson.from.JSON( '{"ident":"c", "name":"UseR", "age":18}' )
d <- mongo.bson.from.list(list(ident    = "d",
                               name     = "foo",
                               age      = 5,
                               comment  = list(first  = "First",
                                               second = "Second")))

if(mongo.is.connected(mongo) == TRUE) {
    icoll <- paste(db, "test", sep=".")
    mongo.insert.batch(mongo, icoll, list(a,b,c,d) )
    
    dbs <- mongo.get.database.collections(mongo, db)
    print(dbs)
    r <- mongo.find.all(mongo, icoll)
    print (r)
}

print(r[[4]]$comment$second)

if(mongo.is.connected(mongo) == TRUE) {
    mongo.update(mongo, icoll, list('ident' = 'b'), list('$inc' = list('age' = 3)))
    
    res <- mongo.find.all(mongo, icoll,
                          query  = list(ident = "b"))
    print(res[[1]])
    
    # Creating an index for the field 'ident'
    mongo.index.create(mongo, icoll, list('ident' = 1))
    # check mongoshell!
}


if(mongo.is.connected(mongo) == TRUE) {
    mongo.drop(mongo, icoll)
    #mongo.drop.database(mongo, db)
    res <- mongo.get.database.collections(mongo, db)
    print(res)
    
    # close connection
    mongo.destroy(mongo)
}


