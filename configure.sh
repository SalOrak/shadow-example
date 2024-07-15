#!/bin/bash
# --------------------------------------------# 
#  Configure dotfiles
#  Author: SalOrak (GitHub)
# --------------------------------------------# 
function display_help(){
	printf "Usage: configure.sh [INSTALL | UNINSTALL] [[-d PATH/TO/DOTIFILES]] [[-s PATH/PREFIX/DOTFILES]] [[-e PATH/PREFIX/DESTINATION]]\n\n"
	printf "\t INSTALL\n\t\tConfigures dotfiles from DOTFILES configuration file.\n\t\tA backup file is saved in backup directory if dotfile exists.\n\t\tBackup directory is \$HOME/.salorak-backups/\n\n"
	printf "\t UNINSTALL\n\t\tDeletes dotfiles configuration from DOTFILES configuration file\n\t\t and reverts it from the .salorak-backups/ directory\n\n"
	printf "\t -d, --dotfiles \n\t\tUses custom directory for the DOTFILES configuration file.\n\n"
	printf "\t -s, --start-dir\n\t\tUses it as PREFIX for finding the DOTFILES.\n\t\tBy default the prefix is the variable \$HOME.\n\n"
	printf "\t -e, --end-dir\n\t\tUses it as PREFIX for the symbolic link.\n\t\tBy default the prefix is the variable \$HOME.\n\t\t\tTip: If you want absolute route use /.\n\n"
}

function check_params(){
	if [[ -z $1  || -z $2 ]]; then
		echo "Arguments cannot be null!"
		return 1
	fi

	if [[ ! -e $1 ]]; then
		echo "File $1 must exist on disk"
		return 1
	fi
	return 0 
}

function sym_link_file(){
	# $1: File to symlink
	# $2: Destination of the symlink
	# $3: Type (INSTALL or UNINSTALL)

    # dirprefix=$HOME

    base=${2##*/} # Filename (DESTINATION)
    dir=${2%$base} # Path without filename (DESTINATION)

    mkdir -p "$dir" 

    case $3 in 
	    INSTALL) 
		    echo "sym_link_file INSTALL"
		    # If dotfile exists, create a backup
		    if [[ -e $2 ]];
		    then
			    #echo "mv -f $2 $BACKUP_DIR/$base"
			    mv -f $2 "$BACKUP_DIR/$base"
		    fi
		    ln -f -s  "$1" "$2"
		    ;;

	    UNINSTALL)
		    echo "sym_link_file UNINSTALL"
		    # if backup exists move it back 
		    if [[ -e "$BACKUP_DIR/$base" ]]
		    then
			    #echo "mv -f $BACKUP_DIR/$base $2"
			    mv -f "$BACKUP_DIR/$base" "$2" # Restore backup file
		    fi
		    ;;
    esac
}

function sym_link_dir(){
	# $1: Directory to symlink
	# $2: Destination of the directory symlink
	# $3: Type (INSTALL or UNINSTALL)
	# $4: PREFIX SOURCE
	# $5: PREFIX DESTINATION


	source_path="$4/$1" # Prefix source + source
	dest_path="$5/$2" # Prefix source + source

	source_files="$source_path/*"


	case $3 in
		INSTALL)
			echo "sym_link_dir INSTALL"

			mkdir -p "$dest_path/" # Create directory

			# If dotfile directory is not empty, create a backup
			if [[ $(find $dest_path -empty) ]];
			then
				mkdir -p "$BACKUP_DIR/$2"
				echo "mv -f $dest_path $BACKUP_DIR/$2"
				rm -rf "$BACKUP_DIR/$2"
				mv -f $dest_path "$BACKUP_DIR/$2"
			fi

			mkdir -p "$dest_path/" # Create directory
			ln -Ff -s $source_path/* $dest_path
			;;
		UNINSTALL)
			echo "sym_link_dir UNINSTALL"
			if [[ -d  "$BACKUP_DIR/$2" ]]
			then
				 rm -rf "$dest_path"
				 mv -f "$BACKUP_DIR/$2" "$dest_path" # Restore backup directory
			fi
			;;
	esac
}

function dotconfig(){
	# $1 --> config file filepath. (DOTFILES)
	# $2 --> Either INSTALL or UNINSTALL
	# $3 --> PREFIX_FILE Prefix for the file path(OPTIONAL)
	# $4 --> PREFIX_DESTINATION Prefix for the destination files (OPTIONAL)

	if [[ $2 != "INSTALL" && $2 != "UNINSTALL" ]]
	then
		echo "$2 is not a valid option"
		exit 1
	fi
	mkdir -p $BACKUP_DIR

	while IFS= read -r line
	do
		line=$(echo $line | tr -d ' ')
		name=$(echo $line | cut -d \| -f 1)
		filepath_d=$(echo $line | cut -d \| -f 2)
		destination_d=$(echo $line | cut -d \| -f 3)
		operation=$(echo $line | cut -d \| -f 4)

		start_prefix=$3
		end_prefix=$4

		filepath="$start_prefix/$filepath_d"
		destination="$end_prefix/$destination_d"
		

		if [[ $name != "Name" ]]; then
			echo -e "\nConfiguring[$name]:\n\tFilepath: $filepath\n\tDestination: $destination\n"
		fi

		case $operation in
			symfile)
				echo "Executing SymFile"
				check_params $filepath $destination
				sym_link_file $filepath $destination $2 
				;;

			symdir)
				echo "Executing SymDirectory"
				check_params $filepath $destination
				sym_link_dir $filepath_d $destination_d $2 $start_prefix $end_prefix
				;;

			Operation)
				;;
			*)
				echo "Unknown operation $operation"
				;;
		esac
	done < "$1"
}

CONFIG_FILES="DOTS" # By default 

case "$(uname -s)" in
    Darwin*) CONFIG_FILES="DOTS_MAC";;
    *) CONFIG_FILES="DOTS";;
esac

BACKUP_DIR="$HOME/.salorak-backups" # Backup directory
PREFIX_FILE="$(pwd)"
PREFIX_DEST="$HOME"

if [[ ! $1 == "INSTALL" && ! $1 == "UNINSTALL" ]]
then
	display_help
	exit 1
else 
	TYPE=$1
	shift;
fi


while [[ "$1" =~ ^- &&  "$1" != "--" ]]; 
do 
	case $1 in
		-h | --help)
			display_help 
			exit
			;;
		-d | --dotfiles)
			shift; CONFIG_FILES=$1
			if [[ ! -e $CONFIG_FILES ]]
			then
				echo "Dotfile $CONFIG_FILES does not exist"
				exit 1
			fi
			;;
		-p | --prefix-directory)
			shift; OPT=$1
			if [[ ! -d $OPT ]]
			then
				echo "Prefix directory $OPT does not exist"
				exit 1
			fi
			;;
		-s | --start-dir)
			shift;PREFIX_FILE=$1
			if [[ -z $PREFIX_FILE ]]
			then
				echo "Prefix directory for DOTFILES can't be an empty string"
				exit 1
			fi
			;;	
		-e | --end-dir)
			shift;PREFIX_DEST=$1
			if [[ -z $PREFIX_DEST ]]
			then
				echo "Prefix directory for destination can't be an empty string"
				exit 1
			fi
			;;	
	esac; 
	shift; 
done

dotconfig $CONFIG_FILES $TYPE $PREFIX_FILE $PREFIX_DEST
