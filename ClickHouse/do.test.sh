#

dataset=$1
offset=$2

ch="clickhouse-client -n -m -t --echo"

(echo Testing for $dataset "(offset $offset)" && \
bash netload_ch.sh $dataset $offset && \
time bash pg.sh) 2>&1 | \
tee log.$dataset.$offset.$(date -u "+%F-%H%M%S").log
