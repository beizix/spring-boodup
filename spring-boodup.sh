#!/bin/sh

GREEN='\033[0;32m'
NC='\033[0m' # No Color

path=$1
domainNm=$2

echo -e "path=$path"

pageable=false
list=false
void=false
implements=false
showCnt=false

set -- $(getopt -o plvis --long pageable,list,void,impl,show -- "$@")
for word in "$@"
do
    case $word in
       -p | --pageable) pageable=true; break ;;
       -l | --list) list=true; break ;;
       -v | --void) void=true; break ;;
       -i | --implements) implements=true; break ;;
    esac   
done

for word in "$@"
do
    case $word in
       -i | --impl) implements=true; ;;
       -s | --show) showCnt=true; ;;
    esac   
done

portPath="/ports"
applicationPath="/application"
domainPath="/domain"
persistPath="/adapters/persistence"
domainFullPath=$path$portPath$applicationPath$domainPath

rm -rf $path

mkdir -p $path$portPath
mkdir -p $domainFullPath
mkdir -p $path/adapters
mkdir -p $path/adapters/web
mkdir -p $path$persistPath

function showContent() {
    if $showCnt; then
        
        echo -e "${GREEN}\n"
        cat $1
        echo -e "${NC}"
    fi    
}


pkgPath=${path##*/src/main/java/}
basePackage=${pkgPath//\//\.}

echo "basePackage=$basePackage"

cmdCreatePath=$pkgPath$portPath$applicationPath$domainPath
cmdPackage=${cmdCreatePath//\//\.}

echo -e "\n"

echo "Creating a Command object.."

cp -f templates/classCommand.tmpl ./
sed -i "s/#package/${cmdPackage}/" ./classCommand.tmpl
sed -i "s/#domainNm/${domainNm}/" ./classCommand.tmpl
mv -f ./classCommand.tmpl "${domainFullPath}/${domainNm}Cmd.java"

echo -e "${domainFullPath}/${domainNm}Cmd.java is created."

showContent "${domainFullPath}/${domainNm}Cmd.java"

if ! $void; then
    echo -e "\n"
    echo "Creating a Domain object.."

    cp -f templates/classReturn.tmpl ./
    sed -i "s/#package/${cmdPackage}/" ./classReturn.tmpl
    sed -i "s/#domainNm/${domainNm}/" ./classReturn.tmpl
    mv -f ./classReturn.tmpl "${domainFullPath}/${domainNm}.java"

    echo "${domainFullPath}/${domainNm}.java is created."

    showContent "${domainFullPath}/${domainNm}.java"
fi

portCreatePath=$pkgPath$portPath
portPackage=${portCreatePath//\//\.}
applCreatePath=$portCreatePath$applicationPath
applPackage=${applCreatePath//\//\.}
daoCreatePath=$pkgPath$persistPath
daoPackage=${daoCreatePath//\//\.}

function createEntity(){
    tmpl=$1
    pkg=$2
    domainNm=$3
    cmdPkg=$4
    fullEntityPath=$5

    cp -f "templates/${tmpl}" ./
    sed -i "s/#package/${pkg}/g" $tmpl
    sed -i "s/#domainNm/${domainNm}/g" $tmpl
    sed -i "s/#cmdPackage/${cmdPkg}/g" $tmpl
    mv -f $tmpl $fullEntityPath

    echo "${fullEntityPath} is created."
}

function createImpl(){
    tmpl=$1
    pkg=$2
    domainNm=$3
    cmdPkg=$4
    portPkg=$5
    fullEntityPath=$6

    cp -f "templates/${tmpl}" ./
    sed -i "s/#package/${pkg}/g" $tmpl
    sed -i "s/#domainNm/${domainNm}/g" $tmpl
    sed -i "s/#portPackage/${portPkg}/g" $tmpl
    sed -i "s/#cmdPackage/${cmdPkg}/g" $tmpl
    mv -f $tmpl $fullEntityPath

    echo "${fullEntityPath} is created."
}

echo -e "\n"

if $pageable; then
    echo "Creating a PortIn interface that returns Pageable.."

    createEntity pageablePortIn.tmpl ${portPackage} ${domainNm} ${cmdPackage} "${path}${portPath}/${domainNm}PortIn.java"
    showContent "${path}${portPath}/${domainNm}PortIn.java"

    echo -e "\n"

    echo "Creating a PortOut interface that returns Pageable.."

    createEntity pageablePortOut.tmpl ${portPackage} ${domainNm} ${portPackage} "${path}${portPath}/${domainNm}PortOut.java"
    showContent "${path}${portPath}/${domainNm}PortOut.java"

    if $implements; then
        echo -e "\n"
        echo "Creating a Service that implements ${domainNm}PortIn.."

        createImpl pageableService.tmpl ${applPackage} ${domainNm} ${portPackage} ${cmdPackage} "${path}${portPath}${applicationPath}/${domainNm}Service.java"
        showContent "${path}${portPath}${applicationPath}/${domainNm}Service.java"

        echo -e "\n"
        echo "Creating a DAO that implements ${domainNm}PortOut.."

        createImpl pageableDao.tmpl ${daoPackage} ${domainNm} ${portPackage} ${cmdPackage} "${path}${persistPath}/${domainNm}Dao.java"
        showContent "${path}${persistPath}/${domainNm}Dao.java"
    fi

elif $list; then    
    echo "Creating a interface that returns List."

    createEntity listPortIn.tmpl ${portPackage} ${domainNm} ${cmdPackage} "${path}${portPath}/${domainNm}PortIn.java"
    showContent "${path}${portPath}/${domainNm}PortIn.java"

    echo -e "\n"

    echo "Creating a PortOut interface that returns Pageable.."

    createEntity listPortOut.tmpl ${portPackage} ${domainNm} ${cmdPackage} "${path}${portPath}/${domainNm}PortOut.java"
    showContent "${path}${portPath}/${domainNm}PortOut.java"

    if $implements; then
        echo -e "\n"
        echo "Creating a Service that implements ${domainNm}PortIn.."

        createImpl listService.tmpl ${applPackage} ${domainNm} ${portPackage} ${cmdPackage} "${path}${portPath}${applicationPath}/${domainNm}Service.java"
        showContent "${path}${portPath}${applicationPath}/${domainNm}Service.java"

        echo -e "\n"
        echo "Creating a DAO that implements ${domainNm}PortOut.."

        createImpl listDao.tmpl ${daoPackage} ${domainNm} ${portPackage} ${cmdPackage} "${path}${persistPath}/${domainNm}Dao.java"
        showContent "${path}${persistPath}/${domainNm}Dao.java"
    fi

elif $void; then    
    echo "Creating a PortIn interface that has no return."

    createEntity voidPortIn.tmpl ${portPackage} ${domainNm} ${cmdPackage} "${path}${portPath}/${domainNm}PortIn.java"
    showContent "${path}${portPath}/${domainNm}PortIn.java"

    echo -e "\n"

    echo "Creating a PortOut interface that has no return."

    createEntity voidPortOut.tmpl ${portPackage} ${domainNm} ${cmdPackage} "${path}${portPath}/${domainNm}PortOut.java"
    showContent "${path}${portPath}/${domainNm}PortOut.java"

    if $implements; then
        echo -e "\n"
        echo "Creating a Service that implements ${domainNm}PortIn.."

        createImpl voidService.tmpl ${applPackage} ${domainNm} ${portPackage} ${cmdPackage} "${path}${portPath}${applicationPath}/${domainNm}Service.java"
        showContent "${path}${portPath}${applicationPath}/${domainNm}Service.java"

        echo -e "\n"
        echo "Creating a DAO that implements ${domainNm}PortOut.."

        createImpl voidDao.tmpl ${daoPackage} ${domainNm} ${portPackage} ${cmdPackage} "${path}${persistPath}/${domainNm}Dao.java"
        showContent "${path}${persistPath}/${domainNm}Dao.java"
    fi

else
    echo "Creating a PortIn interface that returns ${domainNm}."     

    createEntity portIn.tmpl ${portPackage} ${domainNm} ${cmdPackage} "${path}${portPath}/${domainNm}PortIn.java"
    showContent "${path}${portPath}/${domainNm}PortIn.java"

    echo -e "\n"

    echo "Creating a PortOut interface that returns ${domainNm}."

    createEntity portOut.tmpl ${portPackage} ${domainNm} ${cmdPackage} "${path}${portPath}/${domainNm}PortOut.java"
    showContent "${path}${portPath}/${domainNm}PortOut.java"

    if $implements; then
        echo -e "\n"
        echo "Creating a Service that implements ${domainNm}PortIn.."

        createImpl service.tmpl ${applPackage} ${domainNm} ${portPackage} ${cmdPackage} "${path}${portPath}${applicationPath}/${domainNm}Service.java"
        showContent "${path}${portPath}${applicationPath}/${domainNm}Service.java"

        echo -e "\n"
        echo "Creating a DAO that implements ${domainNm}PortOut.."

        createImpl dao.tmpl ${daoPackage} ${domainNm} ${portPackage} ${cmdPackage} "${path}${persistPath}/${domainNm}Dao.java"
        showContent "${path}${persistPath}/${domainNm}Dao.java"
    fi
fi