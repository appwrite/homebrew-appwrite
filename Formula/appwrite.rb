class Appwrite < Formula
  desc "Command-line tool for interacting with the Appwrite API"
  homepage "https://appwrite.io"
  license "BSD-3-Clause"

  def self.binary_arch
    Hardware::CPU.arm? ? "arm64" : "x64"
  end

  def self.binary_os
    return "darwin" if OS.mac?
    return "linux" if OS.linux?

    raise "Homebrew formula is only supported on macOS and Linux"
  end

  def self.binary_name
    "appwrite-cli-#{binary_os}-#{binary_arch}"
  end

  def self.build_target
    return "mac-#{binary_arch}" if OS.mac?
    return "linux-#{binary_arch}" if OS.linux?

    raise "Homebrew formula is only supported on macOS and Linux"
  end

  head "https://github.com/appwrite/sdk-for-cli.git", branch: "master" do
    depends_on "bun" => :build
  end

  # Release automation injects per-target SHA256 values when publishing binaries.
  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/appwrite/sdk-for-cli/releases/download/28.1.0/appwrite-cli-darwin-arm64"
      sha256 "77c2d3a6c8c825ad2b1c5dd35d29727e63b3586408a9ddd297d568e3f9eae8e4"
    else
      url "https://github.com/appwrite/sdk-for-cli/releases/download/28.1.0/appwrite-cli-darwin-x64"
      sha256 "b2f31399ebce947868e061c50d280330060c7a0ede253d694d036575849ceeef"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/appwrite/sdk-for-cli/releases/download/28.1.0/appwrite-cli-linux-arm64"
      sha256 "e4078b0bcdd55b3c95d7a5cd6acc2f65fcae9f5ae92ad9bb12fe1d1706ca9ad2"
    else
      url "https://github.com/appwrite/sdk-for-cli/releases/download/28.1.0/appwrite-cli-linux-x64"
      sha256 "4ca904b1b900ac2db3e1ef46e1b667dd198899be604a81a93012923911ee666f"
    end
  end

  def install
    if build.head?
      system "bun", "install", "--frozen-lockfile"
      system "bun", "run", self.class.build_target
      bin.install "build/#{self.class.binary_name}" => "appwrite"
    else
      bin.install self.class.binary_name => "appwrite"
    end

    (bin/"appwrite").chmod 0755

    generate_completions_from_executable(bin/"appwrite", "completion")
  end

  test do
    assert_match "USAGE", shell_output("#{bin}/appwrite --help")
    assert_match "compdef", shell_output("#{bin}/appwrite completion zsh")
  end
end
