# Pretty Stata Package

*Still being edited heavily and far from a finished project*

## Overview
This is a graphing package that intended to simply graphing attractive graphs in Stata. In particular, this package was designed for use with survey data where respondents may have given answers such as "Unsure", "Refusal", or "Unknown". This package allows for these values using selected codes and then handles them according to the type of graph being created.


## Installation
To install this package, use the package https://github.com/haghish/github.

``` Stata
github install robsfletch/Pretty
```

## Use
Use it exactly the same way you would use the `twoway` graphing command in stata

``` Stata
sysuse auto
pretty_parse scatter price mpg if foreign == 0
```
It should run correctly just like that. There are only two differences in syntax. First, when you specify the `name()` parameter, replace is used by default. Second, if you want to conveniently save files, just use the `save()` option. For example, I can create a graph named *graph1* and save it under the filename *PriceVsMPG.eps* by running

``` Stata
sysuse auto
pretty_parse scatter price mpg if foreign == 0, name("graph1") save("PriceVsMPG.eps")
```


## Uninstallation


``` Stata
github uninstall Pretty
```

## Bugs
I haven't really got the subtitle with the observation count fully working yet. It generally works, but please be cautious. It's easy to comment out that part of the code if it's a problem, so feel free to ask me if it's a problem.
