mkdir -p $HOME/.helpers/
cp docgen.sh $HOME/.helpers/docgen
chmod +x $HOME/.helpers/docgen
echo 'HELPERDIR="$HOME/.helpers"' >> $HOME/.bashrc
echo 'export PATH="$PATH:$HELPERDIR"' >> $HOME/.bashrc
source $HOME/.bashrc
