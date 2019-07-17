#!/usr/bin/bash
while IFS=" " read -r pkg; 
do 


    [ -z ${pkg} ] && help

    REXEC=$(which R)

    if [ -z ${REXEC} ]; then
        echo "R not found, please ensure R is available and try again."
        exit 1
    fi

    echo "install.packages(\"${pkg}\", repos=\"https://cran.rstudio.com/\")" | R --no-save
done < requirements.txt




