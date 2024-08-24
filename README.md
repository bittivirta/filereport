<img alt="Bittivirta Logo" src="https://cdn.bittivirta.fi/logo/logo-auto.svg" height="60" style="float:right;">

# File Report tool

![License](https://img.shields.io/github/license/bittivirta/filereport?style=for-the-badge)

This repository contains the source code for Bittivirta File Report tool. The tool is used to generate reports from a given file. The tool is written in Bash and it is designed to be used in *nix environments. Linux and MacOS are officially supported.

## Usage

The tool can be used without installation by running the following command:

```bash
bash <(curl -Ls 'http://biv.fi/filereport') [file name]
```

For example, to generate a report from a file named `example.zip` run the following command:

```bash
bash <(curl -Ls 'http://biv.fi/filereport') example.zip
```

## Installation

To install the tool to your path (`/usr/local/bin`) run the following command:

```bash
bash <(curl -Ls 'http://biv.fi/filereport-install')
```

After installation, you can run the tool by typing `filereport` in your terminal. For example:

```bash
filereport example.zip
```

## License

This repository is licensed under GNU General Public License v3.0. See the [LICENSE](LICENSE) file for more information.

<kbd>**License:** GPL-3.0-only</kbd>

## Contributing

Feel free to contribute to this project by creating a pull request. The project is open source and we welcome all contributions. We use [Conventional Commits](https://www.conventionalcommits.org/) and [Gitmoji](https://gitmoji.dev/) for commit messages. Please follow these conventions when creating commits.
