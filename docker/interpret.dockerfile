FROM continuumio/anaconda3:latest

ENV LANG=C.UTF-8 LC_ALL=C.UTF-8
ENV PATH /opt/conda/bin:$PATH

# Updating repository sources
# RUN apt-get update

# Installing cron and curl
# RUN apt-get install cron -yqq curl

# Creating directories
RUN mkdir /data
RUN mkdir /notebooks
RUN mkdir /tmp/tflearn_logs

RUN /opt/conda/bin/conda install jupyterlab -y -quiet


# Setting up volumes
VOLUME ["/Work"]

# jupyter
EXPOSE 8888

CMD jupyter lab --notebook-dir=/notebooks --ip=0.0.0.0 --allow-root --port=8888 --no-browser"
