#

import json
import sys

class KtRegistry(object):

    _registers = dict()
#    print("... starting KtRegistry")

    def __init__(self, r_name, r_comment=None):
        self._name = r_name
        self._comment = r_comment
        self._objects = dict()
        self._registers[r_name] = self

    @classmethod
    def get_register(cls, r_name):
        """Retrieve a register from the class directory"""
        return cls._registers[r_name]

    def publish(self, name, **kwargs):
        """Publish into the register"""
        self._objects[name] = kwargs
        return self

    def retrieve(self, name, default=None):
        """Retrieve from register"""
        if default is None:
            return self._objects[name]
        else:
            return self._objects.get(name, default)

    def publish_fun(self, name, **kwargs):
        """Decorator for publishing function"""
        def myfun(fun):
            fun_dict = {'fun': fun}
            fun_dict.update(kwargs)
            self._objects[name] = fun_dict
            return fun
        return myfun

    def run_fun(self, name, *args, default=None, **kwargs):
        """Run function"""
        if default is None:
            fun_dict = self._objects[name]
        else:
            fun_dict = self._objects.get(name,
                                         self._objects[default])
        fun = fun_dict["fun"]
        del fun_dict["fun"]
        kwargs.update(fun_dict)
        return fun(*args, **kwargs)

    def __str__(self):
        """Describe self"""
        return "Registry({name}, {comment}, [".format(
            name = self._name,
            comment = self._comment if self._comment else "None"
            ) + \
            ", ".join(self._objects.keys()) + \
            "])"



    
