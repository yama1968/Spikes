#/usr/bin/python

from dask.distributed import Client, progress

import dask.dataframe as dd
from dask import compute
from sys import argv


def x2df(filename, df_types):

    if filename[-4:] == '.csv':
        return dd.read_csv(filename, dtype=df_types)
    elif filename[-3:] == '.gz':
        return dd.read_csv(filename, compression='gzip', dtype=df_types)
    elif filename[-8:] == '.parquet' or filename[-9] == '.parquet/':
        return dd.read_parquet(filename)
    else:
        return None


def df2parquet(df, filename):

    dd.to_parquet(df, filename)


def x2parquet(from_filename, to_filename, df_types = {}):

    df = x2df(from_filename, df_types)
    df2parquet(df, to_filename)


def parse_dict(dict_string):

    out_dict = {}

    for i in dict_string.split(","):
        one = i.split(":")
        out_dict[one[0]] = one[1]

    return out_dict


if __name__ == '__main__':

    client = Client(processes=False, threads_per_worker=4,
                    n_workers=1, memory_limit='12GB')
    x2parquet(argv[1], argv[2], parse_dict(argv[3]) if len(argv) >= 3 else {})
