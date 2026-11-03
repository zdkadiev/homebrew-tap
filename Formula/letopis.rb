class Letopis < Formula
  desc "Source-linked project memory for AI coding agents"
  homepage "https://github.com/zdkadiev/letopis"
  license "MIT"

  uses_from_macos "git" => :test

  on_macos do
    on_arm do
      url "https://github.com/zdkadiev/letopis/releases/download/v0.1.2/letopis-0.1.2-aarch64-apple-darwin.tar.gz"
      sha256 "16845155ac154fbf2e9dd6386ffac6c15ec022d3d38a86dc96079c55b2561867"
    end
    on_intel do
      url "https://github.com/zdkadiev/letopis/releases/download/v0.1.2/letopis-0.1.2-x86_64-apple-darwin.tar.gz"
      sha256 "c8f33b8bf2b41c1ce72762b4895ca640b9979f3773bf408e1981e362c2db8043"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/zdkadiev/letopis/releases/download/v0.1.2/letopis-0.1.2-aarch64-unknown-linux-gnu.tar.gz"
      sha256 "104914defb322ed5e1cc1c768d9f2103c764633b226e2ab30d31ed65920e9434"
    end
    on_intel do
      url "https://github.com/zdkadiev/letopis/releases/download/v0.1.2/letopis-0.1.2-x86_64-unknown-linux-gnu.tar.gz"
      sha256 "ca38346f2d842ed2c277ac3e5cb74dda441e7c4aa4227c4c2fabfd0f0da57075"
    end
  end

  def install
    bin.install "letopis"
    pkgshare.install "LICENSE", "THIRD_PARTY_NOTICES.txt", "BUILD.json"
  end

  test do
    # Given: a temporary Git worktree with one marked concept.
    system "git", "init", "--quiet"
    (testpath/"knowledge.md").write <<~MARKDOWN
      <!-- letopis: {"created_at":1793491200} -->
      # Retry budget
      Keep retries bounded.
    MARKDOWN
    # When: the installed executable initializes, validates and searches knowledge.
    initialized = JSON.parse(pipe_output("#{bin}/letopis init", "{}\n", 0))
    checked = JSON.parse(pipe_output("#{bin}/letopis check", "{}\n", 0))
    searched = JSON.parse(pipe_output("#{bin}/letopis search", '{"query":"retry","limit":10}', 0))
    # Then: it reports success and finds the authored concept.
    assert_equal true, initialized["ok"]
    assert_equal true, checked["ok"]
    assert_empty checked.fetch("result").fetch("errors")
    assert_equal true, searched["ok"]
    assert_equal ["knowledge.md"], searched.fetch("result").map { |link| link.fetch("element_id") }
    assert_equal "letopis 0.1.2\n", shell_output("#{bin}/letopis --version")
  end
end
