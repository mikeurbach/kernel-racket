# Install

First, [install Racket](https://racket-lang.org/download/).

Then, within this directory, run:

```
raco pkg install
```

Now, `#lang s-exp kernel` and `#lang s-exp kernel/core` should be installed.

# Build Documentation

Within this directory, run:

```
raco setup
```

This will build the user guide. It will be accessible from [doc/kernel-guide/index.html](doc/kernel-guide/index.html).
