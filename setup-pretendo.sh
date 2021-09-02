# Set up some ANSI codes
reset="\e[0m"
title="\e[1;34m"
subtitle="\e[36m"
warning="\e[33mWarning: "
error="\e[1;31mError: "

# Header message
echo -e $title"Simple Pretendo Network setup script"$reset
printf '\e]2;Pretendo setup\a'
echo

# Check that required depedencies are installed
echo -e $subtitle"Git version:"$reset
git --version || echo -e $error"Git is not installed."
echo -e $subtitle"Node.js version:"$reset
node --version || echo -e $error"Node.js is not installed."
echo -e $subtitle"npm version:"$reset
npm --version || echo -e $error"NPM is not installed."
echo -e $subtitle"Go version:"$reset
go version || echo -e $error"Go is not installed."
echo -e $subtitle"MongoDB version:"$reset
mongod --version || echo -e $error"MongoDB is not installed."

# Make sure that a Pretendo folder does not already exist
if [ -d ./PretendoNetwork ]; then
    echo -e $warning"The \"PretendoNetwork\" folder already exists! It will be deleted if you continue!"$reset
fi

# Everything should be set up fine now. It is time to actually start the setup.
echo -e $title"Ready to start downloading the Pretendo files!"$reset
read -p "Would you like to continue? [y/N] " -r
if [[ ! $REPLY =~ ^[Yy]$ ]]; then exit 1; fi

# Create the PretendoNetwork folder
rm -rf PretendoNetwork
mkdir PretendoNetwork
cd PretendoNetwork

# Start by downloading the relevant GitHub repositories
echo -e $title"Cloning the server repositories from GitHub"$reset
git clone --depth 1 https://github.com/PretendoNetwork/account
git clone --depth 1 https://github.com/PretendoNetwork/BOSS
git clone --depth 1 https://github.com/PretendoNetwork/friends-authentication
git clone --depth 1 https://github.com/PretendoNetwork/friends-secure
git clone --depth 1 https://github.com/PretendoNetwork/Grove
git clone --depth 1 https://github.com/PretendoNetwork/juxt-web
git clone --depth 1 https://github.com/PretendoNetwork/olv-api
git clone --depth 1 https://github.com/PretendoNetwork/SOAP
git clone --depth 1 https://github.com/PretendoNetwork/super-mario-maker-authentication
git clone --depth 1 https://github.com/PretendoNetwork/super-mario-maker-secure

# Then download the Go libraries
echo -e $title"Downloading the Go libraries"$reset
go get github.com/PretendoNetwork/nex-go
go get github.com/PretendoNetwork/nex-protocols-go
go get go.mongodb.org/mongo-driver
