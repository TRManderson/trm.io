---
layout: post
title: Extending Celery to Flexibly Support Custom Data Types
categories: python celery serialisation
date:   2017-01-26 21:55:00 +1000
---

## Background

Celery is Python's industrial-strength distributed and asynchronous task queue solution, and provides a convenient API for defining tasks that can be run on asynchronous worker nodes. At [my work](https://polymathian.com) we make heavy use of Celery for running our mathematical optimisation engines, and our web framework for building data visualisation apps, [Tropofy](https://tropofy.com/), has built-in support for Celery.

## The Problem

By default, Celery uses JSON to serialise arguments passed to asynchronous function calls. Unfortunately, this means that any custom classes must use Pickle ([which is considered insecure](https://blog.nelhage.com/2011/03/exploiting-pickle/)), or define a custom serialiser. The latter locks you into a particular serialisation format, just for one extra data type, which I personally don't think is worth the trade off.

## The Solution

The standard way to create Celery tasks is using the `@app.task` decorator, which converts a function into an instance of a Celery `Task` object. By subclassing `Task` to alter the `__call__` and `apply_async` methods, we can provide enough extra information to help Celery out a little, at least where the thing we want to convert is passed in directly as an argument.

Say I have a Celery app `app` and a class `A` that I want to serialise. I'm using Python 3.6 syntax so I can use [variable annotations](https://www.python.org/dev/peps/pep-0526/).


```python
from celery import Celery

app = Celery()

class A(object):
    x: int
    y: str

    def __init__(self, x: int, y: str):
        self.x = x
        self.y = y
```

I can create a `Task` subclass that will convert an instance of `A` to something serialisable as follows:

```python
from celery import Task

class SerialisableAsyncCallTask(Task):
    def apply_async(self, args=None, kwargs=None, *args_, **kwargs_):
        # Convert every arg 
        args = list(args[:])
        for idx, arg in enumerate(args):
            if isinstance(arg, A):
                args[idx] = {'x': arg.x, 'y': arg.y}

        for key, val in kwargs.items():
            if isinstance(val, A):
                kwargs[key] = {'x': val.x, 'y': val.y}

        super().apply_async(args=args, kwargs=kwargs, *args_, **kwargs_)
```

It's not crazy complex, it's just doing an instance check on every argument, then converting if needed. This will totally break my code every time a remote task attempts to run, because it's only converting one way. The above code is just to give you the gist, here's how I'd actually approach doing this generically (including a full implementation).

```python
import importlib
import itertools
from abc import ABCMeta, abstractmethod, abstractclassmethod
from celery import Celery, Task


class AsSerialisable(object, metaclass=ABCMeta):
    @abstractmethod
    def to_serialisable(self): pass

    @abstractclassmethod
    def from_serialisable(data): pass


class ExtendedSerialisableTask(Task):
    @staticmethod
    def _convert_arg_to_serialisable(arg):
        return {
            '__as_serialisable__': True,
            'data': arg.to_serialisable(),
            'class': arg.__class__.__name__,
            'module': arg.__class__.__module__,
        }

    @staticmethod
    def _convert_arg_from_serialisable(arg):
        module = importlib.import_module(arg['module'])
        cls = getattr(module, arg['class'])
        return cls.from_serialisable(arg['data'])

    def apply_async(self, args=None, kwargs=None, *args_, **kwargs_):
        # Convert every arg using `_convert_arg_to_serialisable`
        args = list(args[:])
        for idx, arg in enumerate(args):
            if isinstance(arg, AsSerialisable):
                args[idx] = self._convert_arg_to_serialisable(arg)

        for key, val in kwargs.items():
            if isinstance(val, A):
                kwargs[key] = self._convert_arg_to_serialisable(val)

        super().apply_async(args=args, kwargs=kwargs, *args_, **kwargs_)

    def __call__(self, *args, **kwargs):
        # Unconvert every arg using `_convert_arg_from_serialisable`
        args = list(args)
        for idx, arg in enumerate(args):
            if isinstance(arg, dict) and '__as_serialisable__' in arg:
                args[idx] = self._convert_arg_from_serialisable(arg)

        for key, val in kwargs.items():
            if isinstance(val, dict) and '__as_serialisable__' in val:
                kwargs[key] = self._convert_arg_from_serialisable(val)

        return super().__call__(*args, **kwargs)


class ExtendedCelery(Celery):
    task_cls = ExtendedSerialisableTask

app = ExtendedCelery()
```

We're now using an abstract base class to register things we can convert to something serialisable, which means adding new serialisable classes is just a matter of subclassing (or metaclass registration). We now use class methods on the `Task` subclass to convert to and from the serialisable representations, which means we can cleanly extend the serialised information with enough data to get the class object (which has the `from_serialisable` method).

Other than that, it's basically just arg checking and calling the conversion functions as per the second code block.

## Drawbacks

You can pass in as many `AsSerialisable` objects as arguments as you want, and everything should work nicely. This solution was perfect for my use case and is fairly flexible going forwards, so I'm more than happy to share it, but it's no panacea.

Unfortunately, this doesn't traverse lists/dictionaries/etc to make any references to `AsSerialisable`s serialisable. An extensible and generic API for serialisation could solve this problem to at least some degree, but that's more than a little out of the scope of this post.
