#

import json
import sys
from sys import stderr

from kthelpers import publish
import ktpipes
import pandas as pd


def get_raw(f_name):
    return pd.read_csv(f_name)


ktactions = dict()

@publish(ktactions, "display")
def display(argv, config, transfo, *args):
    """Display the arguments, once unparsed a bit.
    """

    stderr.write("Config is %s\n" % str(config))
    stderr.write("Transfo is %s\n" % str(ktpipes.KtPipe.from_json(config[transfo])))
    stderr.write("Learner is %s\n" % str(learner))


@publish(ktactions, "help")
def default_help(argv, *args, **kwargs):
    """Display help.
    """

    stderr.write("""
Syntax is: %s <action> <config> <dataset> <arg1> ...
With valid actions as:
""" % argv[0])    
    
    for a in ktactions:
        stderr.write("- %s\n" % a)

    sys.exit(-1)


@publish(ktactions, "transform")
def transform(argv, config, data, transfo, dest, *args, **kwargs):
    """Apply transformer to nothing for now.
    """
    
#    stderr.write(str((config, data, transfo) + args) + "\n")
    pipe = ktpipes.KtPipe.from_json(config[transfo])

    result = pipe.fit_transform(get_raw(data))
    
    result.to_csv(dest, index=False)


def past_indice(l, i):
    """Get part of list past i position - included.
    Return [] is list is shorter
    """
    
    return l[i:] if i <= len(l) else []


def main(argv):

    action = argv[1] if len(argv) >= 2 else "help"

    stderr.write("args are: %s.\n" % str(argv))

    if len(argv) >=3:
        with open(argv[2]) as f_config:
            config = json.load(f_config)
    else:
        config = dict()

    return ktactions.get(action, default_help)(argv, config, *argv[3:])
    

if __name__ == "__main__":
    main(sys.argv)
