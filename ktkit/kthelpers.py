# -*- coding: utf-8 -*-
"""
Created on Tue Feb 23 15:30:32 2016

@author: Yannick

Some helpers for the kaggle tolkit package
"""

def publish(register, name):
    """A decorator to publish the function with the name on the register"""
    
    def decorator(fun):
        register[name] = fun
        return fun
    return decorator


