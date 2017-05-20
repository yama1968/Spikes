#!/usr/bin/python


def digit_to_string(d):

    if d < 10:
        return str(d)
    else:
        return chr(d - 10 + ord('A'))


def string_in_base(n, base):

    if n < 0:
        return None
    elif n < base:
        return digit_to_string(n)
    else:
        return string_in_base(n // base, base) + digit_to_string(n % base)


def fusion(a,b):

    if len(a) == 0:
        return b
    elif len(b) == 0:
        return a

    if a[0] <= b[0]:
        return [a[0]] + fusion(a[1:], b)
    else:
        return [b[0]] + fusion(a, b[1:])


def tri_fusion(l):

    if len(l) <= 1:
        return l

    a = tri_fusion(l[0: len(l)//2])
    b = tri_fusion(l[len(l)//2:])

    return fusion(a,b)
