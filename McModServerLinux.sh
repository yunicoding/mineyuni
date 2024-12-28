#!/bin/bash

#****************************************************************************
Start()
#****************************************************************************
{
echo "마인크래프트 모드서버를 설치하겠습니까? [y/n] "
read -r answer
case $answer in
y|Y)
break;;
n|N)
echo Aborting; exit;;
*)
echo "올바른 입력이 아닙니다. 스크립트를 종료합니다."; exit;;
esac

echo
echo
echo "포지버전을 입력해주세요 (예: 1.12.2-14.23.5.2860):"
read -r ForgeVersion

echo
echo
echo "설치하려는 마인크래프트 버전을 입력하세요 (예: 1.16.5, 1.20.1):"
read -r MinecraftVersion

echo
echo "서버 메모리 할당(MB기준)"
read -r MaxMemory
}

#****************************************************************************
ForgeInstall()
#****************************************************************************
{
cd ~
mkdir minecraft && cd minecraft
wget https://maven.minecraftforge.net/net/minecraftforge/forge/${ForgeVersion}/forge-${ForgeVersion}-installer.jar

if [ ${?} != "0" ]
then
echo "포지버전오류"
exit 1
fi
}

#****************************************************************************
JavaInstall()
#****************************************************************************
{
# Minecraft 버전에 따른 Java 버전 매핑
if [[ "$MinecraftVersion" =~ ^1\.(([0-9]|1[0-6])\.[0-9]+)$ ]]; then
JavaVersion=8
elif [[ "$MinecraftVersion" =~ ^1\.(17|18|19)\.[0-9]+$|^1\.20\.[0-4]$ ]]; then
JavaVersion=17
elif [[ "$MinecraftVersion" =~ ^1\.20\.[5-9]$|^1\.2[1-9]\.[0-9]+$ ]]; then
JavaVersion=21
else
echo "알 수 없는 Minecraft 버전입니다. 스크립트를 종료합니다."
exit 1
fi

# Java 설치
echo "Minecraft 버전 $MinecraftVersion에 필요한 Java $JavaVersion을 설치합니다."
sudo apt update

case $JavaVersion in
8)
sudo apt install openjdk-8-jdk -y
;;
17)
sudo apt install openjdk-17-jdk -y
;;
21)
sudo apt install openjdk-21-jdk -y
;;
*)
echo "지원되지 않는 Java 버전입니다. 스크립트를 종료합니다."
exit 1
;;
esac
}

#****************************************************************************
RunInstaller()
#****************************************************************************
{
cd ~/minecraft
java -jar forge-${ForgeVersion}-installer.jar --installServer

if [ ${?} != "0" ]
then
echo "설치오류. 처음부터 다시실행부탁드립니다."
cd ~ && rm -rf ./minecraft
sleep 2
exit 1
fi
}

#****************************************************************************
FirstRun()
#****************************************************************************
{
cd ~/minecraft
java -Xmx${MaxMemory}M -jar forge-${ForgeVersion}.jar nogui
}

#****************************************************************************
EULA()
#****************************************************************************
{
cat <<-EOF > ~/minecraft/eula.txt
eula=true
EOF
}

#****************************************************************************
FireWall()
#****************************************************************************
{
sudo iptables -I INPUT -p udp --dport 25565 -j ACCEPT
sudo iptables -I INPUT -p tcp --dport 25565 -j ACCEPT
sudo netfilter-persistent save
}

#****************************************************************************
# Main Shell Script Start
#****************************************************************************
Start
ForgeInstall
JavaInstall
RunInstaller
FirstRun
EULA
FireWall

echo "서버 설치가 완료 되었습니다."