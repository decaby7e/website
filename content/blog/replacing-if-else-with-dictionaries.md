---
title: Replacing If-Else with Dictionaries in Python
date: 2022-01-25T23:21:00-05:00
draft: false
tags: ["python"]
layout: post
---

A common problem in programming is taking user input and
executing a certain piece of code based on that input.
An example might look like this:

```python3
cmd = input()

if cmd == "command1":
    print("You've run command1!")
elif cmd == "command2":
    print("You've run command2!")
else:
    print("Unknown command specified!")
```

Which works fine for small portions of code, but can get pretty
cumbersome when the code in the if-else blocks becomes a certain
size. We can fix this by moving the code into a function like so:

```python3
def command1():
    print("You've run command1!")

def command2():
    print("You've run command2!")

cmd = input()

if cmd == "command1":
    command1()
elif cmd == "command2":
    command2()
else:
    print("Unknown command specified!")
```

Which is more verbose for this example but for larger functions
of command1 and command2 we start to see benefits. But the problem
with this is that we still have those pesky if-else statements and
that need for error handling at the end. What if we could do better?

Of course, in Python, the answer is always dictionaries:

```python3
def command1():
    print("You've run command1!")

def command2():
    print("You've run command2!")

cmd = input()

# Map each of the functions to an identically
# named string (`"command1": command1`),
# access that function with the bracket operator (`[]`)
# and then call it (`()`)
{"command1": command1, "command2": command2}[cmd]()
```

Who need switch statements when you have this?
This is truly *Pythonic*. It has the added benefit of throwing
a `KeyError` should the command provided not be a real command
and in the case that we need arguments:

```python3
def command1(arg):
    print("You've run command1!")

def command2(arg):
    print("You've run command2!")

cmd, arg = input().split(" ")

{"command1": command1, "command2": command2}[cmd](arg)
```

We only have to specify those arguments once!
