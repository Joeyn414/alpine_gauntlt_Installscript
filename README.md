# alpine_gauntlt_Installscript

this is an install script for an nginx:1.10.0-alpine docker container for gauntlt. There are several tools inside gauntlt but they were first built for a bash environment and not easily portable to alpine. This script allows you to install all the tools inside gauntlt into the aline docker container. I will update the readme page later to give credit to all the tools contributors, the first being gauntlt: https://github.com/gauntlt/gauntlt. Arachni: https://github.com/Arachni/arachni 

Once you are inside the alpine docker container simply cp the gauntltTestInstall.sh script into your container. Then run ./gauntltTestInstall.sh [as of version 1.0 the install took almost 14 minutes]

To verify your code installed cp the readytorumble.sh script into your container then run ./readytorumble.sh and it should echo back with you are ready to rumble.

This container can then be used to scan containers and applicaitons you own. Please do not use this for malicious purposes and the authors of this code assume no liability with the use of this code.
