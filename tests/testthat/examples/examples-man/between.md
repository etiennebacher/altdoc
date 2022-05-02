
### Description

This is a shortcut for `x >= left & x <= right`, implemented efficiently
in C++ for local values, and translated to the appropriate SQL for
remote tables.

### Usage

      between(x, left, right)

### Arguments

<table>
<tbody>
<tr class="odd" data-valign="top">
<td><code>x</code></td>
<td><p>A numeric vector of values</p></td>
</tr>
<tr class="even" data-valign="top">
<td><code>left, right</code></td>
<td><p>Boundary values (must be scalars).</p></td>
</tr>
</tbody>
</table>

### Examples

```r
  between(1:12, 7, 9)

  x <- rnorm(1e2)
  x[between(x, -1, 1)]

  ## Or on a tibble using filter
  filter(starwars, between(height, 100, 150))
```


---
