require 'test/unit'
require_relative '../lib/fiasco/template'

class TestCompiler < Test::Unit::TestCase
  def compile_and_run(body, binding)
    @__result = ''
    s = Fiasco::Template::Compiler.new(output_var: "@__result")
    src = s.compile(body)
    eval src, binding, '(template)', 1
    @__result
  end

  def test_complete
    body = <<-EOT
<head><title>{{title}}</title></head>
<body>
  {% 3.times do |n| %}-{{n}}-{% end %}
  {% 3.times do |n| -%}
     -{{n}}-
     {#- comment #}
  {%- end %}

  % val = '-' * 10
  {{val}}
</body>
EOT

    expected = <<-EOT
<head><title>The Title</title></head>
<body>
  -0--1--2-
  -0--1--2-

  ----------
</body>
EOT

    title = 'The Title'
    result = compile_and_run(body, binding)

    assert_equal expected, result
  end

  def test_expression_substitution
    value = 'value'
    result = compile_and_run('**{{value}} {{ value + value }}**', binding)

    assert_equal '**value valuevalue**', result
  end

  def test_code_blocks
    body = '{% value = 10 %}{% 3.times do %}{{ value * 100 }}{% end %}'
    result = compile_and_run(body, binding)

    assert_equal "100010001000", result
  end

  def test_code_lines
    body = <<-EOT
% 3.times do |n|
Iteration: {{n}}
% end
EOT
    result = compile_and_run(body, binding)

    assert_equal "\nIteration: 0\nIteration: 1\nIteration: 2\n", result
  end

  def test_whitespace_handling
    value = '|value|'

    body = "  \n  {{  value  }}  \n  "
    assert_equal "  \n  |value|  \n  ", compile_and_run(body, binding)

    body = "  \n  {{-  value  }}  \n  "
    assert_equal "|value|  \n  ", compile_and_run(body, binding)

    body = "  \n  {{  value  -}}  \n  "
    assert_equal "  \n  |value|", compile_and_run(body, binding)

    body = "  \n  {{-  value  -}}  \n  "
    assert_equal "|value|", compile_and_run(body, binding)
  end

  def test_comment
    body = "123{# comment #}456"
    assert_equal "123456", compile_and_run(body, binding)
  end

  def test_error_line_mapping
    body = <<-EOT
Line 1
Line {{ 1 + 1 }}
Line {{- 1 + 2 -}}
Line {{ invalid }}
Line 5
EOT
    begin
      compile_and_run(body, binding)
    rescue StandardError => e
      e.backtrace[0] =~ /\(template\):(\d+):.*/
      assert_equal "Error in line: 4", "Error in line: #{$1}"
    end
  end
end
