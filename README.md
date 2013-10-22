Fiasco Template
===============

Templating engine inspired in [Jinja2](http://jinja.pocoo.org/2/).

Introduction
------------

**Compared to ERB**:

- Code blocks are enclosed in `{% ... %}`. This is the same as `<% ... %>` in ERB.
- Inline value expressions are enclosed in `{{ ... }}`. The result of the expression is converted to a string and displayed as part of the output. This is the equivalent of `<%= ... %>` in ERB.
- Comments are similar but enclosed in `{# ... #}`; the contents are discarded.
- Whitespace that appears before the opening tag can be stripped by ending the opening tag with `-` (`{{-`, `{%-`, `{#-`), and whitespace after the closing tag can be stripped by starting the tag with `-` (`-}}`, `-%}`, `-#}`).
- Lines having `%` as their first non-blank character are interpreted as if they were wrapped in `{% ... %}`. The whitespace from the beggining of the line up to `%` is stripped along with the previous line ending.
- There is support for template inheritance similar to what is found in Django templates and Jinja2.
- Support for defining macros (a mix between partials and helper methods), similar to what Jinja2 provides.
- Unlike Rails and Tilt, rendering doesn’t share the context of the caller and is implemented in its own separate context provided by `Fiasco::Template::RenderContext`.

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

# Template Inheritance

Template inheritance lets you define "skeleton" templates with holes to be overriden or extended by child templates (templates that are declared as "extending" a base template).

First the definition of the template that will be used as the base:

`views/base.html`

```html
<!doctype html>
<html>
  <head><title>{% yield_block('title') do %}My Site{% end %}</title></head>
  <body class="{% yield_block('body_classes') %}">
    <div id=wrapper>
      <h1>{% yield_block('title') %}</h1>
      % yield_block('contents')
    </div>
  </body>
</html>
```

Each `yield_block` invocation defines a named block hole in the template that can be referenced in inheriting templates. An optional block can be passed to define the default contents of the block in case the child template doesn't define the block contents (or to use in calls to `superblock` in child templates to include the contents of the parent template)

A *"home"* template that inherits from base is defined like this:

`views/home.html`

```html
% extends 'base'

{% block('title') do %}{% superblock %} -- Homepage{% end %}
% block('contents') do
  <div class=main>
    <h2>This is the homepage</h2>
  </div>
% end
```

The call to `extends` says that this template inherits from a template that was registered under the name *"base"*. The call to `block('title')` defines the contents of the `'title'` block that was declared by the *"base"* template. It calls `superblock` and appends `"-- Homepage"` to the block. The result of this is `"My Site -- Homepage"`.

Because `'title'` was declared twice on the parent template (first for the `<title>` tag, and then for `<h1>`) both places are going to be filled with this value.

On the next line, the contents for the `contents` block are defined, this time without calling `superblock` (which would be meaningless anyway because no default block was provided for the `contents` block. The `body_classes` block is left undefined, and defaults to being empty.

Inheritance can be arbitrarily deep, new blocks can be defined with `yield_block` in `views/home.html` and have other templates inherit from it. Inheriting templates can even declare contents for blocks that *"home"* template is filling with contents and access to what is defined in *"home"* with calls to `superblock` in the same way *"home"* access to block contents defined in *"base"*.

# Macros

Macros are similar in concept to what utility "partials" are in Rails or Sinatra. The difference is that macros are called directly (they are a method like any other, except that they can’t yield, but they can receive explicit blocks)

An example macros file looks like this:

`macros/my_macros.html`

```html
% macro :input, type: 'text', value: '', size: 20 do |name, type, value, size|
  <input type="{{type}}" name="{{name}}" value="{{value}}" size="{{size}}">
% end
% macro :label, required: false do |text, required|
  <label>{{text}}{% if required %}<span class=required>*</span>{% end %}</label>
% end
% macro :field, type: 'text', required: false, label_text: nil do |type, name, label_text, required|
  <div class=field>
    % label text: label_text || name.gsub(/[-_]/, ' ').capitalize, required: required
    % input name: name, type: type
  </div>
% end
```

Here three macros where defined, `input`, `label` and `field`.

`macro` arguments are a name for the macro, a list of default values for the macro arguments (optional), and a block that defines the body of the macro. `input` for example takes one required argument `name:` and three optional arguments `type:`, `value:` and `size:` because they have defaults defined.

To load these macros into the render context:

```ruby
render = Fiasco::Template::RenderContext.new
render.load_macros(path: 'macros/my_macros.html')
```

After loading a macros file, the macros defined on tha file will be available for templates to invoke like in the following example:

`views/users/signup_form.html`

```html
% extends 'base'

% block('main') do
  <form method=post>
    <fieldset>
      % field(name: 'username', value: user.name)
      % field(name: 'password', type: 'password')
      % field(name: 'password_confirm', type: 'password', label_text: 'Password confirmation')
    </fieldset>

    <button>Submit</button>
  </form>
% end
```

Arguments are all passed by name

# More Examples

**TODO**
