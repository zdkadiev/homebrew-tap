class Letopis < Formula
  desc "Source-linked project memory for AI coding agents"
  homepage "https://github.com/zdkadiev/letopis"
  license "MIT"

  uses_from_macos "git" => :test

  on_macos do
    on_arm do
      url "https://github.com/zdkadiev/letopis/releases/download/v0.1.0/letopis-0.1.0-aarch64-apple-darwin.tar.gz"
      sha256 "bba653f8cbbe8861f7507b527559799d18e93d99c72380d0d48fa2c24ded19ef"
    end
    on_intel do
      url "https://github.com/zdkadiev/letopis/releases/download/v0.1.0/letopis-0.1.0-x86_64-apple-darwin.tar.gz"
      sha256 "7c68aa088dfe72dad85a03d683a46e2ab8c6c19028d9d78b76c7a8dcdd0f855e"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/zdkadiev/letopis/releases/download/v0.1.0/letopis-0.1.0-aarch64-unknown-linux-gnu.tar.gz"
      sha256 "d7f6b93d2d21b6445b4fab80554f00da42d3dfbf37d7126893ca00954d378e2b"
    end
    on_intel do
      url "https://github.com/zdkadiev/letopis/releases/download/v0.1.0/letopis-0.1.0-x86_64-unknown-linux-gnu.tar.gz"
      sha256 "5682068028b33710b810a0c31c682a828f187fcd1968e9cc29fc972e4a83e093"
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
    assert_equal "letopis 0.1.0\n", shell_output("#{bin}/letopis --version")
  end
end
