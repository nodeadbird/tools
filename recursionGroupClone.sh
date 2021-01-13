#!/usr/bin/env bash
function getListByKey() {
    json=$1
    key=$2
    echo $json | grep -Po  '"$key":(.+?),' | grep -Po  '\d+'
}

function  groupProjects() {
  groupList=''
  groupList=$(curl -H "PRIVATE-TOKEN: $pricateToken" https://$domin/api/v4/groups?per_page=999)
  #echo $groupList
  idList=(`echo $groupList | grep -Po  '"id":(.+?),' | grep -Po  '\d+'`)
  nameList=(`echo $groupList | grep -Po  '"name":(.+?),'  | awk -F '\"' '{print $4}'`)
  #遍历 group id list
  echo "您有  ${#idList[@]}  个分组 "
  for(( i=0;i<${#idList[@]};i++)) do
    echo  "目录 ${nameList[i]}"
        mkdir  ${nameList[i]}
        cd     ${nameList[i]}

    projectsList=$(curl -H "PRIVATE-TOKEN: $pricateToken" https://$domin/api/v4/groups/${idList[i]}/projects?per_page=999)

    sshList=(`echo $projectsList | grep -Po  '(ssh)://[-A-Za-z0-9+&@#/%?=~_|!:,.;]+[-A-Za-z0-9+&@#/%=~_|]'`)
    for(( j=0;j<${#sshList[@]};j++)) do
      echo "准备克隆第$[$i+1] 分组下的第$[$j+1] 个项目${sshList[j]}";
      git clone ${sshList[j]}
    done
    cd ..
  done;
}


function  allProjects() {
  allList=''
  allList=$(curl -H "PRIVATE-TOKEN: $pricateToken" https://$domin/api/v4/projects?per_page=999)
  #echo $groupList
  sshList=(`echo $allList | grep -Po  '(ssh)://[-A-Za-z0-9+&@#/%?=~_|!:,.;]+[-A-Za-z0-9+&@#/%=~_|]'`)
  for(( j=0;j<${#sshList[@]};j++)) do
    echo "准备克隆第$[$j+1] 个项目${sshList[j]}";
    git clone ${sshList[j]};
  done;
}

FIELD_NAME="http_url_to_repo"

function  groupProjectsByID() {
  local groupList=$(curl -H "PRIVATE-TOKEN: $pricateToken" https://$domin/api/v4/groups/$1/subgroups?per_page=999)
  local idList=(`echo ${groupList} | grep -Po  '"id":(.+?),' | grep -Po  '\d+'`)
  local nameList=(`echo ${groupList} | grep -Po  '"name":(.+?),'  | awk -F '\"' '{print $4}'`)
  echo "分组$1 有  ${#idList[@]}  个分组 "
    if [ ${#idList[@]} == 0 ]
      then
        local projectsList=$(curl -H "PRIVATE-TOKEN: $pricateToken" https://$domin/api/v4/groups/$1/projects?per_page=999)
        local sshList=(`echo $projectsList | grep -o "\"$FIELD_NAME\":[^ ,]\+" | awk -F'"' '{print $4}'`)
#        echo "项目列表： $projectsList"
        echo "分组 $1 下，有 ${#sshList[@]} 项目 "
        for(( j=0;j<${#sshList[@]};j++)) do
          echo "准备克隆第$[$i+1] 分组下的第$[$j+1] 个项目${sshList[j]}";
          git clone ${sshList[j]}
        done
      else
        local idLen=${#idList[@]}
        for(( i=0;i<${idLen};i++)) do
          echo "开始第 $i 个分组"
          echo  "创建目录 ${nameList[i]}"
          mkdir  ${nameList[i]}
          cd     ${nameList[i]}

          local projectsList=$(curl -H "PRIVATE-TOKEN: $pricateToken" https://$domin/api/v4/groups/${idList[i]}/projects?per_page=999)
          local sshList=(`echo $projectsList | grep -Po  '(ssh)://[-A-Za-z0-9+&@#/%?=~_|!:,.;]+[-A-Za-z0-9+&@#/%=~_|]'`)
          echo "分组 ${idList[i]} 下，有 ${#sshList[@]} 项目"
          for(( j=0;j<${#sshList[@]};j++)) do
            echo "准备克隆第$[$i+1] 分组下的第$[$j+1] 个项目${sshList[j]}";
            git clone ${sshList[j]}
          done

          echo "接着查询组ID ${idList[i]}"
          groupProjectsByID ${idList[i]}
          cd ..
          echo "结束第 $i 个分组"
        done;
    fi
}



#JNTMcqKTyytmUxRaWwsx
echo -e "请输入你的私密令牌:  \n如果没有，请前往https://github.com/  项目--个人资料设置--个人访问令牌--创建个人令牌（该令牌再次刷新就无法查看，请记得保存）"
#Private token
read  pricateToken
echo $pricateToken

echo -e "请输入域名"
read domin
echo $domin

echo "下载个人所有项目请输入1，下载所属群组下的项目请输入2，遍历特定群组下面的自群组的所有项目请输入3"
read  putKey
if [ $putKey = "1" ]; then
  allProjects
  break
elif [ $putKey = "2" ]; then
  groupProjects
  break
elif [ $putKey = "3" ]; then
  echo "请输入组ID"
  read putKeyGroupID
  echo -e "groupID：$putKeyGroupID"
  groupProjectsByID $putKeyGroupID
else
  echo "请输入正确的指令"
fi



#while true
#do
#   #Individual group List
##echo "下载个人所有项目请输入1，下载所属群组下的项目请输入2"
##read  putKey
##        if [ $putKey = "1" ]; then
##
##            allProjects
##            break
##            elif [ $putKey = "2" ]; then
##
##            groupProjects
##            break
##            else
##            echo "请输入正确的指令"
##        fi
#echo "请输入组ID"
#read putKeyGroupID
#  echo -e "groupID：$putKeyGroupID"
#  groupProjectsByID $putKeyGroupID
#
#done