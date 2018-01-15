{smcl}
{* *! version 1.2.1  07mar2013}{...}
{findalias asfradohelp}{...}
{vieweralsosee "" "--"}{...}
{vieweralsosee "[R] help" "help help"}{...}
{viewerjumpto "Syntax" "examplehelpfile##syntax"}{...}
{viewerjumpto "Description" "examplehelpfile##description"}{...}
{viewerjumpto "Options" "examplehelpfile##options"}{...}
{viewerjumpto "Remarks" "examplehelpfile##remarks"}{...}
{viewerjumpto "Examples" "examplehelpfile##examples"}{...}
{title:Title}

{phang}
{bf:pretty_loghist} {hline 2} Generate an easily interpretable and well
scaled histogram with a log scale


{marker syntax}{...}
{title:Syntax}

{p 8 17 2}
{cmdab::pretty_loghist}
[{varlist}]
{ifin}
[{cmd:,} {it:options}]

{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Main}
{synopt:{opt unsure}}value to be intepreted as unsure{p_end}
{synopt:{opt refusal}}value to be intepreted as a refusal{p_end}
{synopt:{opt other}}value to be intepreted as other{p_end}
{synopt:{opt na}}value to be intepreted as not applicable{p_end}
{synopt:{opt logbase}}base to use as the log base when binning{p_end}
{synopt:{opt gen}}variable to store the binned variable in{p_end}
{synopt:{opt xlist}}label to use instead of the default labels{p_end}
{synopt:{opt name}}name to be given to the graph{p_end}
{synopt:{opt save}}location to save the file{p_end}
{synoptline}



{marker description}{...}
{title:Description}

{pstd}
{cmd:pretty_loghist} Creates a histogram of the variable in {varlist} 
using a log base and creating an automatic nicely-scaled axis.


{marker options}{...}
{title:Options}

{dlgtab:Main}

{phang}
{opt unsure} value to be intepreted as unsure

{phang}
{opt refusal} value to be intepreted as a refusal

{phang}
{opt other} value to be intepreted as other

{phang}
{opt na} value to be intepreted as not applicable


{marker remarks}{...}
{title:Remarks}

{pstd}
Part of a larger set of pretty graph commands I've created


{marker examples}{...}
{title:Examples}

{phang}{cmd:. sysuse nlsw88}{p_end}

{phang}{cmd:. pretty_loghist wage}{p_end}

{phang}{cmd:. pretty_loghist wage, logbase(1.2) xtitle("log wage") title("Histogram of Log Wage") name("LogWage") save("LogWage.eps")}{p_end}
