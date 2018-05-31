
<!---
	Setup our markdown content.
	--
	NOTE: Indentation is meaningful in Markdown. As such, the fact that our content is
	indented by one tab inside of the CFSaveContent buffer is problematic. But, it makes
	the demo code easier to read. As such, we'll be stripping out the extra tab after the
	content buffer has been defined.
--->
<cfsavecontent variable="markdown">
	
	# About Me

	My name is Ben. I really love to work in the world of web development. Being able to
	turn thoughts into user experiences is just ... well, it's magical. You should check
	out my blog: **www.bennadel.com**.

	I like to write about the following things:

	* Angular
	  * Angular 2+
	  * AngularJS
	* NodeJS
	* ColdFusion
	* SQL
	* ReactJS
	* CSS

	After people read my stuff, they can often be heard to say &mdash; and I quote:

	> Ben who?

	Probably, they are super impressed with my use of white-space in code:

	```js
	function convert( thing ) {

		var mapped = thing.forEach(
			( item ) => {

				return( item.name );

			}
		);

		return( mapped );

	}
	```

	_**NOTE**: I am using [Prism.js](https://prismjs.com/ "Prism is very cool!") to add
	syntax highlighting._

	## The Hard Truth

	Though, it's also possible that people just come for the pictures of my dog:

	[![Lucy the Goose](./goose-duck.jpg)](./goose-duck.jpg "Click to download Goose Duck.")
	
	<style type="text/css">
		img { width: 250px ; }
	</style>

	How <span style="text-transform: uppercase ;">freakin' cute!</span> is that goose?!
	I am such a lucky father!

</cfsavecontent>

<!--- ------------------------------------------------------------------------------ --->
<!--- ------------------------------------------------------------------------------ --->

<cfscript>

	// As per comment above, we need to strip off one tab from each line-start.
	markdown = reReplace( markdown, "(?m)^\t", "", "all" );

	// Create some of our Class definitions. We need this in order to access some static
	// methods and properties.
	AutolinkExtensionClass = application.flexmarkJavaLoader.create( "com.vladsch.flexmark.ext.autolink.AutolinkExtension" );
	HtmlRendererClass = application.flexmarkJavaLoader.create( "com.vladsch.flexmark.html.HtmlRenderer" );
	ParserClass = application.flexmarkJavaLoader.create( "com.vladsch.flexmark.parser.Parser" );

	// Create our options instance - this dataset is used to configure both the parser
	// and the renderer.
	options = application.flexmarkJavaLoader.create( "com.vladsch.flexmark.util.options.MutableDataSet" ).init();

	// Define the extensions we're going to use. In this case, the only extension I want
	// to add is the Autolink extension, which automatically turns URLs into Anchor tags.
	// --
	// NOTE: If you want to add more extensions, you will need to download more JAR files
	// and add them to the JavaLoader class paths.
	options.set(
		ParserClass.EXTENSIONS,
		[
			AutolinkExtensionClass.create()
		]
	);

	// Configure the Autolink extension. By default, this extension will create anchor
	// tags for both WEB addresses and MAIL addresses. But, no one uses the "mailto:"
	// link anymore -- totes ghetto. As such, I am going to configure the Autolink
	// extension to ignore any "link" that looks like an email. This should result in
	// only WEB addresses getting linked.
	options.set(
		AutolinkExtensionClass.IGNORE_LINKS,
		javaCast( "string", "[^@:]+@[^@]+" )
	);

	// Create our parser and renderer - both using the options.
	// --
	// NOTE: In the demo, I'm re-creating these on every page request. However, in
	// production I would probably cache both of these inside of some Abstraction
	// (such as MarkdownParser.cfc) which would, in turn, get cached inside the
	// application scope.
	parser = ParserClass.builder( options ).build();
	renderer = HtmlRendererClass.builder( options ).build();

	// Parse the markdown into an AST (Abstract Syntax Tree) document node.
	document = parser.parse( javaCast( "string", markdown ) );

	// Render the AST (Abstract Syntax Tree) document into an HTML string.
	html = renderer.render( document );

</cfscript>

<!doctype html>
<html lang="en">
<head>
	<meta charset="utf-8" />
	<title>
		Using Flexmark 0.32.24 To Parse Markdown Into HTML in ColdFusion
	</title>
</head>
<body>

	<h1>
		Using Flexmark 0.32.24 To Parse Markdown Into HTML in ColdFusion
	</h1>

	<h2>
		Rendered Output:
	</h2>

	<hr />

	<cfoutput>#html#</cfoutput>

	<hr />

	<h2>
		Rendered Markup:
	</h2>

	<pre class="language-html"
		><code class="language-html"
			><cfoutput>#encodeForHtml( html )#</cfoutput></code></pre>

	<!-- For our fenced code-block syntax highlighting. -->
	<link rel="stylesheet" type="text/css" href="./vendor/prism-1.14.0/prism.css" />
	<script type="text/javascript" src="./vendor/prism-1.14.0/prism.js"></script>

</body>
</html>
