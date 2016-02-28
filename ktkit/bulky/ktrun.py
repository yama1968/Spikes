#

import json
import sys
from sys import stderr

import ktregistry
import ktpipes
import pandas as pd


def get_raw(f_name):
    return pd.read_csv(f_name)


_actions = ktregistry.KtRegistry("actions")

@_actions.publish_fun("display")
def display(config, transfo, learner, *args):
    """Display the arguments, once unparsed a bit.
    """

    stderr.write("Config is %s\n" % str(config))
    stderr.write("Transfo is %s\n" % str(ktpipes.KtPipe.from_json(config[transfo])))
    stderr.write("Learner is %s\n" % str(learner))


@_actions.publish_fun("help")
def default_help(*args, **kwargs):
    """Display help.
    """
    
    stderr.write(str(_actions) + "\n")
    sys.exit(-1)


@_actions.publish_fun("transform")
def transform(config, data, transfo, *args, **kwargs):
    """Apply transformer to nothing for now.
    """
    
#    stderr.write(str((config, data, transfo) + args) + "\n")
    pipe = ktpipes.KtPipe.from_json(config[transfo])

    return pipe.fit_transform(get_raw(data))


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

    return _actions.run_fun(action, config, *argv[3:],
                            default = "help")

if __name__ == "__main__":
    main(sys.argv)
