#!/bin/bash

docker run --gpus all--name pytorch -i -t -p 8821:8888 \
    -v "$HOME/Work:/opt/Work" -d pytorch_yma02  \
    /bin/bash -c "conda activate base /
                  jupyter lab --allow-root --notebook-dir=/opt/Work \
                    --ip=0.0.0.0 --port=8888 --no-browser --NotebookApp.token=yma"
