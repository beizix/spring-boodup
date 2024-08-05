#!/bin/sh


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
        
        echo -e "\n"
        cat $1
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

echo -e "\n"

if $pageable; then
    echo "Creating a PortIn interface that returns Pageable.."

    cp -f templates/pageablePortIn.tmpl ./
    sed -i "s/#package/${portPackage}/g" ./pageablePortIn.tmpl
    sed -i "s/#domainNm/${domainNm}/g" ./pageablePortIn.tmpl
    sed -i "s/#cmdPackage/${cmdPackage}/g" ./pageablePortIn.tmpl
    mv -f ./pageablePortIn.tmpl "${path}${portPath}/${domainNm}PortIn.java"

    echo "${path}${portPath}/${domainNm}PortIn.java is created."

    showContent "${path}${portPath}/${domainNm}PortIn.java"

    echo -e "\n"

    echo "Creating a PortOut interface that returns Pageable.."

    cp -f templates/pageablePortOut.tmpl ./
    sed -i "s/#package/${portPackage}/g" ./pageablePortOut.tmpl
    sed -i "s/#domainNm/${domainNm}/g" ./pageablePortOut.tmpl
    sed -i "s/#cmdPackage/${portPackage}/g" ./pageablePortOut.tmpl
    mv -f ./pageablePortOut.tmpl "${path}${portPath}/${domainNm}PortOut.java"

    echo "${path}${portPath}/${domainNm}PortOut.java is created."

    showContent "${path}${portPath}/${domainNm}PortOut.java"

    if $implements; then
        echo -e "\n"
        echo "Creating a Service that implements ${domainNm}PortIn.."

        cp -f templates/pageableService.tmpl ./
        sed -i "s/#package/${applPackage}/g" ./pageableService.tmpl
        sed -i "s/#domainNm/${domainNm}/g" ./pageableService.tmpl
        sed -i "s/#portPackage/${portPackage}/g" ./pageableService.tmpl
        sed -i "s/#cmdPackage/${cmdPackage}/g" ./pageableService.tmpl
        mv -f ./pageableService.tmpl "${path}${portPath}${applicationPath}/${domainNm}Service.java"

        echo "${path}${portPath}${applicationPath}/${domainNm}Service.java is created."

        showContent "${path}${portPath}${applicationPath}/${domainNm}Service.java"

        echo -e "\n"
        echo "Creating a DAO that implements ${domainNm}PortOut.."

        cp -f templates/pageableDao.tmpl ./
        sed -i "s/#package/${daoPackage}/g" ./pageableDao.tmpl
        sed -i "s/#domainNm/${domainNm}/g" ./pageableDao.tmpl
        sed -i "s/#portPackage/${portPackage}/g" ./pageableDao.tmpl
        sed -i "s/#cmdPackage/${cmdPackage}/g" ./pageableDao.tmpl
        mv -f ./pageableDao.tmpl "${path}${persistPath}/${domainNm}Dao.java"

        echo "${path}${persistPath}/${domainNm}Dao.java is created."

        showContent "${path}${persistPath}/${domainNm}Dao.java"
    fi

elif $list; then    
    echo "Creating a interface that returns List."

    cp -f templates/listPortIn.tmpl ./
    sed -i "s/#package/${portPackage}/g" ./listPortIn.tmpl
    sed -i "s/#domainNm/${domainNm}/g" ./listPortIn.tmpl
    sed -i "s/#cmdPackage/${cmdPackage}/g" ./listPortIn.tmpl
    mv -f ./listPortIn.tmpl "${path}${portPath}/${domainNm}PortIn.java"

    echo "${path}${portPath}/${domainNm}PortIn.java is created."

    showContent "${path}${portPath}/${domainNm}PortIn.java"

    echo -e "\n"

    echo "Creating a PortOut interface that returns Pageable.."

    cp -f templates/listPortOut.tmpl ./
    sed -i "s/#package/${portPackage}/g" ./listPortOut.tmpl
    sed -i "s/#domainNm/${domainNm}/g" ./listPortOut.tmpl
    sed -i "s/#cmdPackage/${cmdPackage}/g" ./listPortOut.tmpl
    mv -f ./listPortOut.tmpl "${path}${portPath}/${domainNm}PortOut.java"

    echo "${path}${portPath}/${domainNm}PortOut.java is created."

    showContent "${path}${portPath}/${domainNm}PortOut.java"

    if $implements; then
        echo -e "\n"
        echo "Creating a Service that implements ${domainNm}PortIn.."

        cp -f templates/listService.tmpl ./
        sed -i "s/#package/${applPackage}/g" ./listService.tmpl
        sed -i "s/#domainNm/${domainNm}/g" ./listService.tmpl
        sed -i "s/#portPackage/${portPackage}/g" ./listService.tmpl
        sed -i "s/#cmdPackage/${cmdPackage}/g" ./listService.tmpl
        mv -f ./listService.tmpl "${path}${portPath}${applicationPath}/${domainNm}Service.java"

        echo "${path}${portPath}${applicationPath}/${domainNm}Service.java is created."

        showContent "${path}${portPath}${applicationPath}/${domainNm}Service.java"

        echo -e "\n"
        echo "Creating a DAO that implements ${domainNm}PortOut.."

        cp -f templates/listDao.tmpl ./
        sed -i "s/#package/${daoPackage}/g" ./listDao.tmpl
        sed -i "s/#domainNm/${domainNm}/g" ./listDao.tmpl
        sed -i "s/#portPackage/${portPackage}/g" ./listDao.tmpl
        sed -i "s/#cmdPackage/${cmdPackage}/g" ./listDao.tmpl
        mv -f ./listDao.tmpl "${path}${persistPath}/${domainNm}Dao.java"

        echo "${path}${persistPath}/${domainNm}Dao.java is created."

        showContent "${path}${persistPath}/${domainNm}Dao.java"
    fi

elif $void; then    
    echo "Creating a PortIn interface that has no return."

    cp -f templates/voidPortIn.tmpl ./
    sed -i "s/#package/${portPackage}/g" ./voidPortIn.tmpl
    sed -i "s/#domainNm/${domainNm}/g" ./voidPortIn.tmpl
    sed -i "s/#cmdPackage/${cmdPackage}/g" ./voidPortIn.tmpl
    mv -f ./voidPortIn.tmpl "${path}${portPath}/${domainNm}PortIn.java"

    echo "${path}${portPath}/${domainNm}PortIn.java is created."

    showContent "${path}${portPath}/${domainNm}PortIn.java"

    echo -e "\n"

    echo "Creating a PortOut interface that has no return."

    cp -f templates/voidPortOut.tmpl ./
    sed -i "s/#package/${portPackage}/g" ./voidPortOut.tmpl
    sed -i "s/#domainNm/${domainNm}/g" ./voidPortOut.tmpl
    sed -i "s/#cmdPackage/${cmdPackage}/g" ./voidPortOut.tmpl
    mv -f ./voidPortOut.tmpl "${path}${portPath}/${domainNm}PortOut.java"

    echo "${path}${portPath}/${domainNm}PortOut.java is created."

    showContent "${path}${portPath}/${domainNm}PortOut.java"

    if $implements; then
        echo -e "\n"
        echo "Creating a Service that implements ${domainNm}PortIn.."

        cp -f templates/voidService.tmpl ./
        sed -i "s/#package/${applPackage}/g" ./voidService.tmpl
        sed -i "s/#domainNm/${domainNm}/g" ./voidService.tmpl
        sed -i "s/#portPackage/${portPackage}/g" ./voidService.tmpl
        sed -i "s/#cmdPackage/${cmdPackage}/g" ./voidService.tmpl
        mv -f ./voidService.tmpl "${path}${portPath}${applicationPath}/${domainNm}Service.java"

        echo "${path}${portPath}${applicationPath}/${domainNm}Service.java is created."

        showContent "${path}${portPath}${applicationPath}/${domainNm}Service.java"

        echo -e "\n"
        echo "Creating a DAO that implements ${domainNm}PortOut.."

        cp -f templates/voidDao.tmpl ./
        sed -i "s/#package/${daoPackage}/g" ./voidDao.tmpl
        sed -i "s/#domainNm/${domainNm}/g" ./voidDao.tmpl
        sed -i "s/#portPackage/${portPackage}/g" ./voidDao.tmpl
        sed -i "s/#cmdPackage/${cmdPackage}/g" ./voidDao.tmpl
        mv -f ./voidDao.tmpl "${path}${persistPath}/${domainNm}Dao.java"

        echo "${path}${persistPath}/${domainNm}Dao.java is created."

        showContent "${path}${persistPath}/${domainNm}Dao.java"
    fi

else
    echo "Creating a PortIn interface that returns ${domainNm}."     

    cp -f templates/portIn.tmpl ./
    sed -i "s/#package/${portPackage}/g" ./portIn.tmpl
    sed -i "s/#domainNm/${domainNm}/g" ./portIn.tmpl
    sed -i "s/#cmdPackage/${cmdPackage}/g" ./portIn.tmpl
    mv -f ./portIn.tmpl "${path}${portPath}/${domainNm}PortIn.java"

    echo "${path}${portPath}/${domainNm}PortIn.java is created."

    showContent "${path}${portPath}/${domainNm}PortIn.java"

    echo -e "\n"

    echo "Creating a PortOut interface that returns ${domainNm}."

    cp -f templates/portOut.tmpl ./
    sed -i "s/#package/${portPackage}/g" ./portOut.tmpl
    sed -i "s/#domainNm/${domainNm}/g" ./portOut.tmpl
    sed -i "s/#cmdPackage/${cmdPackage}/g" ./portOut.tmpl
    mv -f ./portOut.tmpl "${path}${portPath}/${domainNm}PortOut.java"

    echo "${path}${portPath}/${domainNm}PortOut.java is created."

    showContent "${path}${portPath}/${domainNm}PortOut.java"

    if $implements; then
        echo -e "\n"
        echo "Creating a Service that implements ${domainNm}PortIn.."

        cp -f templates/service.tmpl ./
        sed -i "s/#package/${applPackage}/g" ./service.tmpl
        sed -i "s/#domainNm/${domainNm}/g" ./service.tmpl
        sed -i "s/#portPackage/${portPackage}/g" ./service.tmpl
        sed -i "s/#cmdPackage/${cmdPackage}/g" ./service.tmpl
        mv -f ./service.tmpl "${path}${portPath}${applicationPath}/${domainNm}Service.java"

        echo "${path}${portPath}${applicationPath}/${domainNm}Service.java is created."

        showContent "${path}${portPath}${applicationPath}/${domainNm}Service.java"

        echo -e "\n"
        echo "Creating a DAO that implements ${domainNm}PortOut.."

        cp -f templates/dao.tmpl ./
        sed -i "s/#package/${daoPackage}/g" ./dao.tmpl
        sed -i "s/#domainNm/${domainNm}/g" ./dao.tmpl
        sed -i "s/#portPackage/${portPackage}/g" ./dao.tmpl
        sed -i "s/#cmdPackage/${cmdPackage}/g" ./dao.tmpl
        mv -f ./dao.tmpl "${path}${persistPath}/${domainNm}Dao.java"

        echo "${path}${persistPath}/${domainNm}Dao.java is created."

        showContent "${path}${persistPath}/${domainNm}Dao.java"
    fi
fi