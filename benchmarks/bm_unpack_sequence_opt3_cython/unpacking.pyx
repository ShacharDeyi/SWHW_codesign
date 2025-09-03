# fast_unpack.pyx
# Compile-only optimization of the inner unpack loop.
# - Keeps runner logic in Python
# - Supports tuples and lists (length must be 10)
# - Performs exactly 400 unpack operations per outer iteration

# cython: language_level=3
cimport cython
from cpython.tuple cimport PyTuple_CheckExact, PyTuple_GET_SIZE, PyTuple_GET_ITEM
from cpython.list  cimport PyList_CheckExact,  PyList_GET_SIZE,  PyList_GET_ITEM
from cpython.ref   cimport PyObject

@cython.boundscheck(False)
@cython.wraparound(False)
def do_unpacking_cython(int loops, object to_unpack):
    """
    Mirrors the original: for each of `loops`, perform 400 unpackings of
    10 variables from `to_unpack`. Supports tuple or list.
    """
    cdef Py_ssize_t ii, k
    cdef Py_ssize_t n
    cdef object a, b, c, d, e, f, g, h, i, j

    # Fast paths for tuple/list of length 10
    if PyTuple_CheckExact(to_unpack):
        n = PyTuple_GET_SIZE(to_unpack)
        if n != 10:
            raise ValueError("to_unpack must have length 10 (tuple)")
        for ii in range(loops):
            for k in range(400):
            # exactly 400 repeats of the same unpack
                # (borrowed refs from GET_ITEM; assignment to Python locals
                #  handles INCREF/DECREF correctly)
                a  = <object>PyTuple_GET_ITEM(to_unpack, 0)
                b  = <object>PyTuple_GET_ITEM(to_unpack, 1)
                c  = <object>PyTuple_GET_ITEM(to_unpack, 2)
                d  = <object>PyTuple_GET_ITEM(to_unpack, 3)
                e  = <object>PyTuple_GET_ITEM(to_unpack, 4)
                f  = <object>PyTuple_GET_ITEM(to_unpack, 5)
                g  = <object>PyTuple_GET_ITEM(to_unpack, 6)
                h  = <object>PyTuple_GET_ITEM(to_unpack, 7)
                i = <object>PyTuple_GET_ITEM(to_unpack, 8)
                j  = <object>PyTuple_GET_ITEM(to_unpack, 9)
        return None

    if PyList_CheckExact(to_unpack):
        n = PyList_GET_SIZE(to_unpack)
        if n != 10:
            raise ValueError("to_unpack must have length 10 (list)")
        for i in range(loops):
            for k in range(400):
                a  = <object>PyList_GET_ITEM(to_unpack, 0)
                b  = <object>PyList_GET_ITEM(to_unpack, 1)
                c  = <object>PyList_GET_ITEM(to_unpack, 2)
                d  = <object>PyList_GET_ITEM(to_unpack, 3)
                e  = <object>PyList_GET_ITEM(to_unpack, 4)
                f  = <object>PyList_GET_ITEM(to_unpack, 5)
                g  = <object>PyList_GET_ITEM(to_unpack, 6)
                h  = <object>PyList_GET_ITEM(to_unpack, 7)
                i = <object>PyList_GET_ITEM(to_unpack, 8)
                j  = <object>PyList_GET_ITEM(to_unpack, 9)
        return None

    # Fallback: any sequence convertible via tuple(), with strict length check
    # (keeps logic identical while still accelerating the inner loop)
    to_unpack = tuple(to_unpack)
    if len(to_unpack) != 10:
        raise ValueError("to_unpack must have length 10")
    for i in range(loops):
        for k in range(400):
            a, b, c, d, e, f, g, h, ii, j = to_unpack
    return None
