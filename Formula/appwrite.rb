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
      url "https://github.com/appwrite/sdk-for-cli/releases/download/28.5.0/appwrite-cli-darwin-arm64"
      sha256 "3f7d13366b67033bddcdf5bafeb87e3451c1fd4236276a7ac54fbb0f7aa4b8cc"
    else
      url "https://github.com/appwrite/sdk-for-cli/releases/download/28.5.0/appwrite-cli-darwin-x64"
      sha256 "bbe102ae53ee9575c32e9c9a2ad87a78f58705d7aceae689116c56ae468b1f06"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/appwrite/sdk-for-cli/releases/download/28.5.0/appwrite-cli-linux-arm64"
      sha256 "d501c71c2b7fd862156c93c6e01cb47b61ee047f50f7457ac7ffb6a106349bd5"
    else
      url "https://github.com/appwrite/sdk-for-cli/releases/download/28.5.0/appwrite-cli-linux-x64"
      sha256 "0b16497e1383a2d49cba766da9731744db72593eb7612f384ab475eca7171607"
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
