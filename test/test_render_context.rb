require 'test/unit'
require_relative '../lib/fiasco/template'

$renderer = Fiasco::Template::RenderContext.new

Dir['./test/templates/*.html'].each do |path|
  name = path.gsub(/\.html$/, '').gsub('./test/templates/', '')
  $renderer.declare(name, path: path)
end

$renderer.load_macros(path: './test/macros/fields.html')

class TestRender < Test::Unit::TestCase
  def test_simple_render
    expected = <<-EOS
<!doctype html>
<html>
  <head><title>My Site</title></head>
  <body class="">
    <div id=wrapper>
      <h1>My Site</h1>
    </div>
  </body>
</html>
EOS

    assert_equal expected, $renderer.render('base')
  end

  def test_inheritance
    expected = <<-EOS
<!doctype html>
<html>
  <head><title>My Site -- Homepage</title></head>
  <body class="">
    <div id=wrapper>
      <h1>My Site -- Homepage</h1>
      <div class=main>
        <h2>This is the homepage</h2>
      </div>
    </div>
  </body>
</html>
EOS

    assert_equal expected, $renderer.render('child')
  end

  def test_nested_inheritance
    expected = <<-EOS
<!doctype html>
<html>
  <head><title>My Site -- Homepage</title></head>
  <body class="">
    <div id=wrapper>
      <h1>My Site -- Homepage</h1>
      Grandchild
    </div>
  </body>
</html>
EOS

    assert_equal expected, $renderer.render('grandchild')
  end

  def test_locals
    assert_equal "a b\n", $renderer.render('with_locals',
                                           local1: 'a', local2: 'b')
  end

  def test_macros
    expected = <<-EOS
<form method=post>
  <fieldset>
  <div class=field>
  <label>Username</label>
  <input type="text" name="username" value="" size="20">
  </div>
  <div class=field>
  <label>Password</label>
  <input type="password" name="password" value="" size="20">
  </div>
  <div class=field>
  <label>Password confirm</label>
  <input type="password" name="password_confirm" value="" size="20">
  </div>
  </fieldset>

  <button>Submit</button>
</form>
EOS

    assert_equal expected, $renderer.render('uses_macros', user_name: 'Admin')
  end
end
