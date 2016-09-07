# Create a shell script which can be run during a CHORDS app startup 
# in order to set some useful environment variables.

chords_env_script='./chords_env.sh'

CHORDS_GIT_BRANCH=`git rev-parse --abbrev-ref HEAD`
CHORDS_GIT_SHA=`git rev-parse HEAD`
CHORDS_BUILD_TIME=`date +"%F %T %Z"`

echo "#"                                               
echo "# Source this script in order to"                
echo "# set useful CHORDS environment values"          
echo "#"                                               
echo "export CHORDS_GIT_SHA=\"$CHORDS_GIT_SHA\""       
echo "export CHORDS_GIT_BRANCH=\"$CHORDS_GIT_BRANCH\"" 
echo "export CHORDS_BUILD_TIME=\"$CHORDS_BUILD_TIME\"" 
echo "#"                                               
echo "echo CHORDS environment settings:"               
echo "echo CHORDS_GIT_SHA=\$CHORDS_GIT_SHA"            
echo "echo CHORDS_GIT_BRANCH=\$CHORDS_GIT_BRANCH"      
echo "echo CHORDS_BUILD_TIME=\$CHORDS_BUILD_TIME"      

#chmod a+x $chords_env_script
