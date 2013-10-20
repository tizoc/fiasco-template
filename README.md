Fiasco Template
===============

Templating engine inspired in [Jinja2](http://jinja.pocoo.org/2/).

Usage
-----

An instance of `Fiasco::Template::RenderContext` has to be created first, then templates
can be declared on that object.

```ruby
renderer = Fiasco::Template::RenderContext.new

renderer.declare('template_name', contents: 'Hello {{name}}')
renderer.render('template_name', name: 'Fiasco') # => 'Hello Fiasco'
renderer['template_name', name: 'Fiasco'] # => 'Hello Fiasco'
```

Display blocks are delimited by `{{` and `}}` and contain any ruby expression.

Code blocks are delimited by `{%` and `%}`, they contain arbitrary Ruby code.

```ruby
renderer.declare('with_code', contents: '{% 10.times do %}.{% end %}')
renderer['with_code'] # => '..........'
```

Code lines start with `%`, they work like code blocks but instead of a closing tag, the end of line terminates the block.

```ruby
template_body = <<-EOS
% 10.times do |n|
  - {{n}} * {{n}} = {{n * n}}
% end
EOS
renderer.declare('with_code_lines', contents: template_body)
renderer['with_code_lines']
```

Renders

```

  - 0 * 0 = 0
  - 1 * 1 = 1
  - 2 * 2 = 4
  - 3 * 3 = 9
  - 4 * 4 = 16
  - 5 * 5 = 25
  - 6 * 6 = 36
  - 7 * 7 = 49
  - 8 * 8 = 64
  - 9 * 9 = 81
```

Comment blocks are delimited by `{#` and `#}` and are ignored.

# Whitespace

Opening tags can end with `-`, if they do then preceding whitespace is trimmed.

Closing tags can start with `-`, if they do then trailing whitespace is trimmed.

Code lines remove all preceding whitespace up to (and including) the nearest newline.

# Macros

**TODO**

# Examples

**TODO**
