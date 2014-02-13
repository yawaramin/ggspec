# Contributing

Emailed patches or GitHub pull requests welcome. Please note the
important caveat below:

_Always work in your own branch._ The way I have things set up right
now, the `guile-2` branch is more of a patch series, i.e. a floating
head. It will always move around to stay on top of `master`. This is
because the changes required to port ggspec to Guile 2 are mostly
trivial, and I targeted Guile 1.8 first. That's just the way it worked
out.

If and when I stop supporting Guile 1.8, `guile-2` will be merged into
`master` once and for all and there will be a `guile-3` floating branch,
probably, to annoy you.

Meanwhile, working in your own branch will help you because when you
pull the latest commits, `guile-2` will point at some other commit but
you will be working with your own history in your own branch and will be
able to easily rebase onto the new `guile-2`.

## Branches

With that out of the way here's a description of the branches that I'm
using currently:

  - `master`: a ready-to-ship version of ggspec, targetting Guile 1.8.

  - `guile-2`: a ready-to-ship version of ggspec, targetting Guile 2. As
    I explain above, this is a floating head; don't rely on it to
    preserve SHA history. When I stop supporting Guile 1.8 and start
    targetting Guile 2 by default, this branch will be merged in to
    `master`.

  - `devel`: a work-in-progress branch that will periodically be merged
    back in to `master`. This branch exists to serve as a backup of the
    work on my computer; use at your own discretion.

