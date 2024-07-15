# dotfiles

Automatic installation of apps and configuration files onto the filesystem. It only works on POSIX (tested on macOS and Debian) systems.

## Usage

```bash
./configure --help

Usage: configure.sh [INSTALL | UNINSTALL] [[-d PATH/TO/DOTIFILES]] [[-s PATH/PREFIX/DOTFILES]] [[-e PATH/PREFIX/DESTINATION]]

	 INSTALL
		Configures dotfiles from DOTFILES configuration file.
		A backup file is saved in backup directory if dotfile exists.
		Backup directory is $HOME/.salorak-backups/

	 UNINSTALL
		Deletes dotfiles configuration from DOTFILES configuration file
		 and reverts it from the .salorak-backups/ directory

	 -d, --dotfiles 
		Uses custom directory for the DOTFILES configuration file.

	 -s, --start-dir
		Uses it as PREFIX for finding the DOTFILES.
		By default the prefix is the variable $HOME.

	 -e, --end-dir
		Uses it as PREFIX for the symbolic link.
		By default the prefix is the variable $HOME.
			Tip: If you want absolute route use /.

```

## Personal DOTS file
This project also contains an example with my personal configuration files.
And yes, I'm both a Neovim user and an Emacs user :)

## DOTS file

The **DOTS** file is compose of rows (dot files) and properties.
Currently it supports the following columns:
- **Name**: (Optional) A name describing the DOT file.
- **Filepath**: [Required] The location path of the DOT file to use as base. This path should point to a valid file or directory. By default it uses the current directory as a prefix. 
- **Destination**: [Required] Location to place the symlink to take place for the app. Each application searches config files in different places. By default it uses the $HOME variable as prefix. 
- **Operation**: [Required] Type of symbolic link. It can either be `symfile` for singular configuration files or `symdir` for complete (recursive) directories. Other operation skips the row.

## TODO List

- [X] Add argument to change **Filepath** prefix.
- [X] Add argument to change **Destination** prefix.

## License

Uses the MIT License.

[What is MIT Licensy by Snyk.io](https://snyk.io/learn/what-is-mit-license/)
>The MIT license are to grant permissions and indemnify developers for future use. Specifically, it grants any person who obtains a copy of the software and associated files the right to use, copy, modify, merge, distribute, publich, sublicense, and sell copies of the software. 
>The only condition required to use the software is to include the same copyright notice in all copies or any substantial portions of the software. The final portion of the text provides for limitations and revokes any warranty implied by sharing the code. 

