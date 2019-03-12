## General
This web site is built using jekyll and bootstrap.

I started with creating a new jekyll site:

    jekyll new chords_pages

Jekyll does not employ bootstrap out of the box, and so we must
integrate the two. There seem to be many ways to do this, and I relied
more or less on the instructions found at
[jekyll-with-twitter-bootstrap-sass](http://jekyll.pygmeeweb.com/2014/08/02/jekyll-with-twitter-bootstrap-sass/).
Similar guidance is provided by [Veithen](http://veithen.github.io/2015/03/26/jekyll-bootstrap.html). 
These instructions point out that this is an "authorized" version
of bootstrap, created for use with sass. There are probably simple ways
to integrate the vanilla bootstrap with jekyll. It's all very
confusing.

Note that jekyll and boostrap each have their own frameworks for layout
and styling. By choosing to use boostrap, we are essentially abandoning
the default jekyll styling. This means finding and replacing the jekyll
css class references with ones from bootstrap, or copying/creating
replacements. I'm not sure that I have completely finished this. But
the pages seem to look pretty good.

## _config.yml
Tell jekyll to use a different _sass directory, which contains the bootstrap styling:

    sass:
        sass_dir: assets/stylesheets

## Syntax Highlighting
Jekyll seems to support pygments highlighting out of the box, but for 
some reason I couldn't just copy and use _sass/_syntax-highlighting.css
straight away. Instead, I founded and downloaded _syntax.css_ and 
created _css/syntax.css_. I then added to header.html:

      <link rel="stylesheet" href="{{ "/css/syntax.css" | prepend: site.baseurl }}">



