
import random
from datetime import datetime
import pandas as pd
import numpy as np
import sys

from sklearn import preprocessing


def get_raw(dir="../data", variant=""):

    train = pd.read_csv(dir + "/train" + variant + ".csv")
    test = pd.read_csv(dir + "/test" + variant + ".csv")

    return (train, test)


class FeaturePrep(object):

    def fit(self, df, y=None):
        return self

    def fit_transform(self, df, y=None):
        self.fit(df, y)
        return self.transform(df)


class CleanComma(FeaturePrep):

    def __init__(self, field_list):
        self.field_list = field_list

    def transform(self, df, y=None):
        for f in self.field_list:
            df[f] = df[f].str.replace(",", "").astype(int)
        return df


class AddBusDay(FeaturePrep):

    def __init__(self, date_field="Original_Quote_Date"):
        FeaturePrep.__init__(self)
        self.date_field = date_field

    def transform(self, df):
        df_dates = pd.to_datetime(pd.Series(df[self.date_field]))
        df.is_busday = 1 * np.is_busday(df_dates)
        return df


class FixDates(FeaturePrep):

    def transform(self, df):

        # Convert to date
        dates = pd.to_datetime(pd.Series(df['Original_Quote_Date']))
        df = df.drop('Original_Quote_Date', axis=1)

        # Seperating date into 3 columns
        df['Year'] = dates.apply(lambda x: int(str(x)[:4]))
        df['Month'] = dates.apply(lambda x: int(str(x)[5:7]))
        df['weekday'] = dates.dt.dayofweek

        return df


class FixNA(FeaturePrep):

    def __init__(self, na_value=-99):
        self.na_value = na_value

    def fit(self, df, y=None):
        return self

    def transform(self, df):

        return df.fillna(self.na_value)


def has_na(s):
    return s.isnull().sum() > 0


class AddHasNA(FeaturePrep):

    def fit(self, df, y=None):
        self.with_na = [f for f in df if has_na(df[f])]
        sys.stderr.write("Adding NA for columns %s.\n" % str(self.with_na))
        FeaturePrep.fit(self, df, y)
        return self

    def transform(self, df):

        for f in self.with_na:
            df["na_" + f] = 1 * df[f].isnull()
        return df


class FixCat2Int(FeaturePrep):

    def __init__(self):
        self.dicties = {}
        self.unk = "<<unknown>>"

    def fit(self, df, y=None):

        self.dicties = {}
        self.legals = {}

        for f in df.columns:
            if df[f].dtype == 'O':
                lbl = preprocessing.LabelEncoder()
                self.legals[f] = list(df[f].values)
                lbl.fit(self.legals[f] + ['<<unknown>>'])
                self.dicties[f] = lbl

        return self

    def transform(self, df):

        for f in self.dicties:
            new_removed = df[f].apply(
                lambda x: x if x in self.legals[f] else self.unk)
            df[f] = self.dicties[f].transform(list(new_removed))

        return df


class FixDrop(FeaturePrep):

    def __init__(self, droplist):
        self.droplist = droplist

    def fit(self, df, y=None):
        return self

    def transform(self, df):
        return df.drop(self.droplist, axis=1)


class FixPipe(FeaturePrep):

    def __init__(self, trfs):
        self.trfs = trfs

    def fit_transform(self, df, y=None):
        df1 = df
        for t in self.trfs:
            df1 = t.fit_transform(df1)
        return df1

    def fit(self, df, y=None):
        self.fit_transform(df, y)
        return self

    def transform(self, df):
        df1 = df
        for t in self.trfs:
            df1 = t.transform(df1)
        return df1


class OrderedLabelEncoder(object):

    def __init__(self, default_key):
        self.default_key = default_key

    def fit(self, l):
        self.mydict = {v: i for (i, v) in enumerate(l)}
        return self

    def transform(self, l, y=None):
        d = self.mydict
        default_value = d[self.default_key]
        return [d.get(v, default_value)
                for v in l]


class FixCat2IntOrdered(FixCat2Int):

    def __init__(self, target):
        self.target = target
        FixCat2Int.__init__(self)

    def fit(self, df, y=None):
        self.legals = {}

        for f in df.columns:
            if df[f].dtype == 'O':
                lbl = OrderedLabelEncoder(self.unk)
                props = df.groupby(f)[self.target].mean()
                lprops = len(props)
                props[self.unk] = df[self.target].mean()
                props.sort_values(inplace=True)
                self.legals[f] = list(props.index)
                lbl.fit(self.legals[f])
                self.dicties[f] = lbl

        return self


class AddPseudoEmpiricalBayes(FeaturePrep):

    def __init__(self, target, threshold=0.02, forced={}, min_nb_values=0):
        self.threshold = threshold
        self.target = target
        self.mydict = {}
        self.forced = forced
        self.target_mean = None
        self.min_nb_values = min_nb_values

    def fit(self, df, y=None):
        self.props = {}
        self.target_mean = df[self.target].mean()
        nb = len(df)

        for f in df.columns:
            if df[f].dtype == 'O' or f in self.forced:
                if len(np.unique(df[f])) >= self.min_nb_values:
                    qt = df.groupby(f)[f].count()
                    props = df.groupby(f)[self.target].mean()
                    props = props[qt >= nb * self.threshold]
                    self.mydict[f] = props
#                    sys.stderr.write("Kept for '%s' = %s\n" % (f, props))
        return self

    def transform(self, df):
        for f in self.mydict:
            df["peb_" + f] = [
                self.mydict[f].get(x, self.target_mean)
                for x in df[f]
            ]
        return df


class AddGolden(FeaturePrep):

    def __init__(self, golden):
        self.golden = golden

    def transform(self, df):
        for featureA, featureB in self.golden:
            df["_".join([featureA, featureB, "diff"])] = \
                df[featureA] - df[featureB]
        return df


class RemoveEnd(FeaturePrep):

    def __init__(self, letter):
        self.letter = letter

    def transform(self, df):
        drop_features = [f for f in df.columns if f[-1:] == self.letter]
        sys.stderr.write("Dropping: %s\n" % str(drop_features))
        return df.drop(drop_features, axis=1)
