# Create a shell scrit which can be run during a CHORDS app startup 
# in order to set some useful environment variables.

chords_env_script='./chords_env.sh'

CHORDS_GIT_BRANCH=`git rev-parse --abbrev-ref HEAD`
CHORDS_GIT_SHA=`git rev-parse HEAD`

echo "#"                                               >  $chords_env_script
echo "# Source this script in order to"                >> $chords_env_script
echo "# set useful CHORDS environment values"          >> $chords_env_script
echo "#"                                               >> $chords_env_script
echo "export CHORDS_GIT_SHA=\"$CHORDS_GIT_SHA\""       >> $chords_env_script
echo "export CHORDS_GIT_BRANCH=\"$CHORDS_GIT_BRANCH\"" >> $chords_env_script
echo "#"                                               >> $chords_env_script
echo "echo CHORDS environment settings:"               >> $chords_env_script
echo "echo CHORDS_GIT_SHA=\$CHORDS_GIT_SHA"            >> $chords_env_script
echo "echo CHORDS_GIT_BRANCH=\$CHORDS_GIT_BRANCH"      >> $chords_env_script

chmod a+x $chords_env_script
