
LOAD DATA INFILE '/media/sf_Documents/tmp/train1M.csv' 
INTO TABLE train2
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;