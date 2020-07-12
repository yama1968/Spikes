#!/bin/bash

docker run --name interpret -i -t -p 8821:8888 \
    -v "$HOME/Work:/opt/Work" -d continuumio/anaconda3  \
    /bin/bash -c "/opt/conda/bin/conda install jupyterlab -y --quiet && 
                  /opt/conda/bin/conda init bash /
                  /opt/conda/bin/conda activate base /
                  /opt/conda/bin/jupyter lab --allow-root --notebook-dir=/opt/Work \
                    --ip=0.0.0.0 --port=8888 --no-browser --NotebookApp.token=yma"

# apt-get update && apt-get upgrade
# apt-get install libc-dev gcc gfortran g++ make cmake
# conda activate base
# pip install xgboost interpret hyperopt
