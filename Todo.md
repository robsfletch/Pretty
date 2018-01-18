# To-Do List

## Redo architecture
-   The base of this package should just be a wrapper around twoway graph that can accept any type of twoway graph.
-   The log thing should then be a separate thing added on to that in the case that a log base is desired for a particular axis.

## Redo switch for when it works
-   There's an if statement for when I have specific code written for a given function. The if isn't quite right in that it should be able to pick up on scatter, scatte, scatt, scat, etc. for example, but currently does not. I could do this by hand but maybe there's a nicer way.

## Passing options that are not in twoway
-   The algorithm should check for these and then pass them appropriately. So far we have all the survey code values and the cdf option for hist.

## Minor
-   Redo the histogram default to be frac but still allows the other ones. Basically, check for all three, make sure there is only one, and then go with frac if none are specified.
