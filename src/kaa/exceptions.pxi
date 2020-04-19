from cpython.ref cimport PyObject


from .kaacore.exceptions cimport setup_kaacore_error_class


class KaacoreError(Exception):
    pass


setup_kaacore_error_class(<PyObject*>KaacoreError)
