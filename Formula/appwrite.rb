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
      url "https://github.com/appwrite/sdk-for-cli/releases/download/28.13.2/appwrite-cli-darwin-arm64"
      sha256 "707fd57c6673ba46585a74c1613781e6400495492803a0e9d9b9d89b80a7e1cd"
    else
      url "https://github.com/appwrite/sdk-for-cli/releases/download/28.13.2/appwrite-cli-darwin-x64"
      sha256 "0ddac1be5c2315e0180d01cce8b5bee1559dfa86a6ac9692fa38310ddeb0c1b1"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/appwrite/sdk-for-cli/releases/download/28.13.2/appwrite-cli-linux-arm64"
      sha256 "a01a261f77588b5bd51023246d0ffe2880d88651924d07f0e212d686f505b598"
    else
      url "https://github.com/appwrite/sdk-for-cli/releases/download/28.13.2/appwrite-cli-linux-x64"
      sha256 "17cf96b4a898ad6d3d9f18c777343acb29d8fca36d2c0101a3db30889696552d"
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
