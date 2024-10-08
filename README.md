<img alt="Bittivirta Logo" src="https://cdn.bittivirta.fi/logo/logo-auto.svg" height="60" style="float:right;">

# File Report Tool

![License](https://img.shields.io/github/license/bittivirta/filereport?style=for-the-badge)
![GitHub last commit](https://img.shields.io/github/last-commit/bittivirta/filereport?style=for-the-badge)
![GitHub release (latest by date)](https://img.shields.io/github/v/release/bittivirta/filereport?style=for-the-badge)
![Version](https://img.shields.io/badge/version-1.0.0-blue?style=for-the-badge)

This repository contains the source code for the Bittivirta File Report Tool. The tool is used to generate reports from a given file. It is written in Bash and is designed to be used in *nix environments. Linux and macOS are officially supported.

## Screenshot

![Screenshot](/img/screenshot.webp)

Example markdown report generated is available in the [example.md](example.md) file.

## Usage

The tool can be used without installation by running the following command:

```bash
bash <(curl -Ls 'http://biv.fi/filereport') [file name]
```

For example, to generate a report from a file named `example.zip`, run the following command:

```bash
bash <(curl -Ls 'http://biv.fi/filereport') example.zip
```

## Installation

To install the tool to your path (`/usr/local/bin`), run the following command:

```bash
bash <(curl -Ls 'http://biv.fi/filereport-install')
```

After installation, you can run the tool by typing `filereport` in your terminal. For example:

```bash
filereport example.zip
```

## Updating

To update the tool to the latest version, run the insallation command again:

```bash
bash <(curl -Ls 'http://biv.fi/filereport-install')
```

## Uninstallation

To uninstall the tool, run the following command:

```bash
rm /usr/local/bin/filereport
```

The tool is now uninstalled from your system. The installation script does not create any other files or directories. The tool is also self-contained and does not require any dependencies.

## License

This repository is licensed under the GNU General Public License v3.0. See the [LICENSE](LICENSE) file for more information.

<kbd>**License:** GPL-3.0-only</kbd>

## Contributing

Feel free to contribute to this project by creating a pull request. The project is open source, and we welcome all contributions. We use [Conventional Commits](https://www.conventionalcommits.org/) and [Gitmoji](https://gitmoji.dev/) for commit messages. Please follow these conventions when creating commits.
