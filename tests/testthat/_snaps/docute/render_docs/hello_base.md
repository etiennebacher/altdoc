

# Base function

## Description

Base function

## Usage

<pre><code class='language-R'>hello_base(x = 2)
</code></pre>

## Arguments

<table role="presentation">
<tr>
<td style="white-space: collapse; font-family: monospace; vertical-align: top">
<code id="x">x</code>
</td>
<td>
A parameter
</td>
</tr>
</table>

## Details

Some code with weird symbols: <code>pl$when(condition)</code> and
<code>pl$then(output)</code>

Some equations: ∂*Y*/∂*X* = *a* + *ε*/2

## Value

Some value

## References

Ihaka R, Gentleman R (1996). R: A Language for Data Analysis and
Graphics. <em>Journal of Computational and Graphical Statistics</em>.
<b>5</b>(3), 299–314.
[doi:10.2307/139080](https://doi.org/10.2307/139080)

## See Also

<code>print</code>, <code>hello_r6</code>

## Examples

``` r
library("testpkg.altdoc")

hello_base()
```

    [1] "Hello, world!"

``` r
mtcars$drat <- mtcars$drat + 1
head(mtcars[["drat"]], 2)
```

    [1] 4.9 4.9
