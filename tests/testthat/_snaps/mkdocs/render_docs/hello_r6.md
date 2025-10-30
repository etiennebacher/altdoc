

# Create a "conductor" tour

## Description

blah blah blah

## Methods

<h4>
Public methods
</h4>
<ul>
<li>

<a href="#method-Conductor-new"><code>hello_r6$new()</code></a>

</li>
<li>

<a href="#method-Conductor-init"><code>hello_r6$init()</code></a>

</li>
<li>

<a href="#method-Conductor-step"><code>hello_r6$step()</code></a>

</li>
<li>

<a href="#method-Conductor-clone"><code>hello_r6$clone()</code></a>

</li>
</ul>
<hr>

<a id="method-Conductor-new"></a>

<h4>
Method <code>new()</code>
</h4>
<h5>
Usage
</h5>

<pre>hello_r6\$new()</pre>

<h5>
Details
</h5>

Initialise <code>Conductor</code>.

<hr>

<a id="method-Conductor-init"></a>

<h4>
Method <code>init()</code>
</h4>
<h5>
Usage
</h5>

<pre>hello_r6\$init(session = NULL)</pre>

<h5>
Arguments
</h5>

<dl>
<dt>
<code>session</code>
</dt>
<dd>
A valid Shiny session. If <code>NULL</code> (default), the function
attempts to get the session with
<code>shiny::getDefaultReactiveDomain()</code>.
</dd>
</dl>

<h5>
Details
</h5>

Initialise <code>Conductor</code>.

<hr>

<a id="method-Conductor-step"></a>

<h4>
Method <code>step()</code>
</h4>
<h5>
Usage
</h5>

<pre>hello_r6\$step(title = NULL)</pre>

<h5>
Arguments
</h5>

<dl>
<dt>
<code>title</code>
</dt>
<dd>
Title of the popover.
</dd>
</dl>

<h5>
Details
</h5>

Add a step in a <code>Conductor</code> tour.

<hr>

<a id="method-Conductor-clone"></a>

<h4>
Method <code>clone()</code>
</h4>

The objects of this class are cloneable with this method.

<h5>
Usage
</h5>

<pre>hello_r6\$clone(deep = FALSE)</pre>

<h5>
Arguments
</h5>

<dl>
<dt>
<code>deep</code>
</dt>
<dd>
Whether to make a deep clone.
</dd>
</dl>
