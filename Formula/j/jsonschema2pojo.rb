class Jsonschema2pojo < Formula
  desc "Generates Java types from JSON Schema (or example JSON)"
  homepage "https://www.jsonschema2pojo.org/"
  url "https://github.com/joelittlejohn/jsonschema2pojo/releases/download/jsonschema2pojo-1.3.2/jsonschema2pojo-1.3.2.tar.gz"
  sha256 "dbc806217bca8b242378c261c563c59f949cfe4bc70d84439eedba4bb7ae4776"
  license "Apache-2.0"

  livecheck do
    url :stable
    regex(/jsonschema2pojo[._-]v?(\d+(?:\.\d+)+)/i)
    strategy :github_latest
  end

  bottle do
    sha256 cellar: :any_skip_relocation, all: "ad532cb32089ba32d3c1725c429053620ce47eb5ecffeceaa92abb2513fe9280"
  end

  depends_on "openjdk"

  def install
    libexec.install "jsonschema2pojo-#{version}-javadoc.jar", "lib"
    bin.write_jar_script libexec/"lib/jsonschema2pojo-cli-#{version}.jar", "jsonschema2pojo"
  end

  test do
    (testpath/"src/jsonschema.json").write <<~JSON
      {
        "type":"object",
        "properties": {
          "foo": {
            "type": "string"
          },
          "bar": {
            "type": "integer"
          },
          "baz": {
            "type": "boolean"
          }
        }
      }
    JSON
    system bin/"jsonschema2pojo", "-s", "src", "-t", testpath
    assert_path_exists testpath/"Jsonschema.java", "Failed to generate Jsonschema.java"
  end
end
