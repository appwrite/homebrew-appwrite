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
      url "https://github.com/appwrite/sdk-for-cli/releases/download/27.1.0/appwrite-cli-darwin-arm64"
      sha256 "501719a33a704e220ebcc9c9285b0af22a6399a918678f13ab63c30b79a388b4"
    else
      url "https://github.com/appwrite/sdk-for-cli/releases/download/27.1.0/appwrite-cli-darwin-x64"
      sha256 "b9c0c030655b909a59357f4185db565bb2aa1264421679bdbc18fd57ef9564ed"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/appwrite/sdk-for-cli/releases/download/27.1.0/appwrite-cli-linux-arm64"
      sha256 "7fe591d0bac6cd737bc60ca68961626ca65cc0ce444bbaf9bc52c4d7adeffb84"
    else
      url "https://github.com/appwrite/sdk-for-cli/releases/download/27.1.0/appwrite-cli-linux-x64"
      sha256 "d3752e19d06de936fa27742a46d4653137a920de20ea72437c4de2ca4fef2313"
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
