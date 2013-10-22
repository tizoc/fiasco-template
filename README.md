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

TODO

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

# Examples

**TODO**
