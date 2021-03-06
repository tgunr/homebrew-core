require "language/node"
require "json"

class Webpack < Formula
  desc "Bundler for JavaScript and friends"
  homepage "https://webpack.js.org/"
  url "https://registry.npmjs.org/webpack/-/webpack-4.3.0.tgz"
  sha256 "c5b9483bff07fa51b60cc2cf0f9872ca1ece6db517e6147d138673f9a9366f7e"
  head "https://github.com/webpack/webpack.git"

  bottle do
    sha256 "818fab54e92ca8d95f208709e5bc2dcd7b5897d7b1912348cec92d2a518c3cb5" => :high_sierra
    sha256 "0224c4011e52c08ad441f4bef4e2963dadb81be44357dbb3b99343ceb474c89c" => :sierra
    sha256 "c41d1886135833d7c451e3082055d54ae14fb05daf50beb26fedc4317c369def" => :el_capitan
  end

  depends_on "node"

  resource "webpack-cli" do
    url "https://registry.npmjs.org/webpack-cli/-/webpack-cli-2.0.13.tgz"
    sha256 "971d03c08c3d6b13b8c3f24b3b76ddd1da8a9fb6c9754abac03ad41fbaadeabb"
  end

  def install
    (buildpath/"cli/node_modules/webpack").install Dir["*"]
    (buildpath/"cli").install resource("webpack-cli")

    cd buildpath/"cli" do
      # declare webpack as a bundledDependency of webpack-cli
      pkg_json = JSON.parse(IO.read("package.json"))
      pkg_json["dependencies"]["webpack"] = version
      pkg_json["bundledDependencies"] = ["webpack"]
      IO.write("package.json", JSON.pretty_generate(pkg_json))

      system "npm", "install", *Language::Node.std_npm_install_args(libexec)
    end

    bin.install_symlink libexec/"bin/webpack-cli"
    bin.install_symlink libexec/"bin/webpack-cli" => "webpack"
  end

  test do
    (testpath/"index.js").write <<~EOS
      function component () {
        var element = document.createElement('div');
        element.innerHTML = 'Hello' + ' ' + 'webpack';
        return element;
      }

      document.body.appendChild(component());
    EOS

    system bin/"webpack", "index.js", "--output=bundle.js"
    assert_predicate testpath/"bundle.js", :exist?, "bundle.js was not generated"
  end
end
