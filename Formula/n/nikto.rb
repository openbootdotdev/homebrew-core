class Nikto < Formula
  desc "Web server scanner"
  homepage "https://cirt.net/nikto/"
  url "https://github.com/sullo/nikto/archive/refs/tags/2.6.0.tar.gz"
  sha256 "656554f9aeba8c462689582b59d141369dbcadac11141cd02752887f363430ec"
  license "GPL-2.0-only"

  livecheck do
    url :stable
    regex(/^v?(\d+(?:\.\d+)+)$/i)
  end

  bottle do
    rebuild 1
    sha256 cellar: :any_skip_relocation, all: "ab8f5f0295ab3a4599a11e2cb63486c8da93c91c0088bc6f29307db3aec3df58"
  end

  def install
    cd "program" do
      inreplace "nikto.pl", "/etc/nikto.conf", "#{etc}/nikto.conf"

      inreplace "nikto.conf.default" do |s|
        s.gsub! "# EXECDIR=/opt/nikto", "EXECDIR=#{prefix}"
        s.gsub! "# PLUGINDIR=/opt/nikto/plugins",
                "PLUGINDIR=#{pkgshare}/plugins"
        s.gsub! "# DBDIR=/opt/nikto/databases",
                "DBDIR=#{var}/nikto/databases"
        s.gsub! "# TEMPLATEDIR=/opt/nikto/templates",
                "TEMPLATEDIR=#{pkgshare}/templates"
        s.gsub! "# DOCDIR=/opt/nikto/docs", "DOCDIR=#{doc}"
      end

      bin.install "nikto.pl" => "nikto"
      bin.install "utils/replay.pl" => "replay.pl"
      etc.install "nikto.conf.default" => "nikto.conf"
      pkgshare.install "plugins", "templates"
    end

    man1.install "documentation/nikto.1"
    doc.install Dir["documentation/*"]
    (var/"nikto/databases").mkpath
    cp_r Dir["program/databases/*"], var/"nikto/databases"
  end

  test do
    system bin/"nikto", "-H"
  end
end
