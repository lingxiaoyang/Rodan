# Adapted from http://stackoverflow.com/questions/1254454/fastest-way-to-convert-a-dicts-keys-values-from-unicode-to-str

import collections


def convert_to_unicode(data):
    if isinstance(data, str):
        return str(data)
    elif isinstance(data, collections.Mapping):
        return dict(list(map(convert_to_unicode, iter(data.items()))))
    elif isinstance(data, collections.Iterable):
        return type(data)(list(map(convert_to_unicode, data)))
    else:
        return data
