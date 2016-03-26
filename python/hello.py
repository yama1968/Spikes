#


def fact(n):
    if n <= 1:
        return 1
    else:
        return n * fact(n - 1)


print("hello!")

n = 20

print("Fact(%d) = %d" % (n, fact(n)))
