#!/bin/bash

function print_msg()
{
    echo -e "$1"
}

# check if user is root
function assert_root()
{
	if [[ $EUID -ne 0 ]]; then
   		print_msg "This script must be run as root"
 		exit 1
	fi
}

# help options
function usage()
{
cat <<EOF
  usage: $0 options

  Script used to setup a basic development environment for several programming languages

  OPTIONS:
     -h      Show this message
     -c      Install and configure chruby and the latest versions of Ruby, JRuby and Rubinius
     -i      Install ruby-install
     -g      Install git version control system
     -v      Increase verbosity
EOF
}

# check if package is installed via apt-get
function apt_package_query()
{
    print_msg "checking for package: $1"
    PKG_OK=$(dpkg-query -W --showformat='${Status}\n' $1|grep "install ok installed")
    if [ "" == "$PKG_OK" ]; then
        return 0
    else
        return 1
    fi
}

# install package via apt-get
function apt_package_install()
{
    PKG=$1

    apt_package_query $PKG
    if [ $? == 1 ]; then
        print_msg "package '$PKG' already installed"
    else
        print_msg "installing: '$PKG'"
        sudo apt-get -y install $PKG
    fi
}

# install dependencies for this script
function install_dependencies()
{
	apt_package_install curl
}

# install git version control system
function install_git()
{
	apt_package_install git

	GCONF=$HOME/.gitconfig

	if [ ! -f $GCONF ]; then
	    touch $GCONF
	    echo -e "[color]\nstatus = auto\nbranch = auto\nui = auto" >> $GCONF
	fi
}

# install chruby ruby version manager
function install_chruby()
{
	if ! assert_root; then
		return 1
	fi

	print_msg "Downloading and extracting chruby..."
	wget -O - "https://github.com/postmodern/chruby/archive/v0.3.6.tar.gz" | tar -xvzf -

	print_msg "Installing chruby and the latest releases of Ruby, JRuby and Rubinius..."
	(cd chruby-0.3.6 && make install &&  ./scripts/setup.sh)
  #  add to bashrc "source /usr/local/share/chruby/chruby.sh"
}

# install ruby-install library
function install_ruby-install()
{
  if ! assert_root; then
    return 1
  fi

  print_msg "Downloading and extracting ruby-install..."
  wget -O - "https://github.com/postmodern/ruby-install/archive/v0.2.1.tar.gz" | tar -xvzf -

  print_msg "Installing ruby-install..."
  (cd ruby-install-0.2.1 && make install && rm -r ruby-install-0.2.1)
}

# TODO: replace with normal case setup
while getopts "hcig" opt
do
	case $opt in
		h)
			usage
			;;
		c)
			install_chruby
			;;
    i)
      install_ruby-install
      ;;
		g)
			install_git
			;;
		\?)
			# refactor into method
			usage
			exit 1
			;;
	esac
done

#apt-get -y install vim-gnome build-essential libssl-dev git curl bison openssl libreadline6 libreadline6-dev git-core zlib1g zlib1g-dev libyaml-dev libsqlite3-0 libsqlite3-dev sqlite3 libxml2-dev libxslt-dev autoconf libc6-dev ncurses-dev automake ssh php5-cli

#NVM=$HOME/.nvm

#if [ ! -d $NVM ]; then
#    git clone git://github.com/creationix/nvm.git $NVM
#    echo "\n\n. ~/.nvm/nvm.sh #Load NVM function" >> $HOME/.bashrc
#    chmod 777 $HOME/.nvm
#fi

#RVM=$HOME/.rvm
#
#if [ ! -d $RVM ]; then
#    curl -s https://rvm.beginrescueend.com/install/rvm -o rvm-installer
#    chmod +x rvm-installer
#    su dennis -c './rvm-installer --version latest'
#    echo "\n\n[[ -s $RVM/scripts/rvm ]] && . $RVM/scripts/rvm # Load RVM function" >> $HOME/.bashrc
#fi


#source bashrc?
