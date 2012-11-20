#!/bin/bash


# auto merge/checkout/sync script for my build env
# this script should be put into the $ANDROIDTOP dir

base=`pwd`

github=https://github.com
cm_base_url=$github/CyanogenMod
mm_base_url=https://bitbucket.org/MagicDevTeam
mFetchUrl=""
cm_remote_name=cyanogen
mm_remote_name=magic
cm_cur_branch=jellybean-stable
MM_TRUE=1
MM_FALSE=0

# magic_special_repos
# jb-maigc is our branch
# jellybean is for cm branch
# repo in this list is our private repos, stored in bitbucket.org
magic_special_repos="frameworks/base
             packages/apps/Contacts
             packages/apps/Mms
             packages/apps/Phone
             packages/apps/Settings
             vendor/cm"
           
# magic_common_repos
# jellybean is our branch
# jb-cm is cm branch
# repo in this list is stored in github as public repos
magic_common_repos="build
                    development
                    frameworks/av
                    frameworks/native
                    hardware/libhardware
                    hardware/libhardware_legacy
                    hardware/ril
                    packages/apps/Bluetooth
                    packages/apps/Stk
                    packages/apps/VoiceDialer
                    packages/providers/ContactsProvider
                    packages/providers/DrmProvider
                    packages/providers/TelephonyProvider
                    system/core"

function mm_checkout(){
  dirPath=$base/$1
  if [ ! -d $dirPath ];then
      echo "Error: Dir $dirPath not found "
      return $MM_FALSE
  fi
  cd $dirPath
  echo "checkout [$1] into <$2>"
  #ret=`git checkout $2`
  #return $ret
  git checkout $2
  return $?
}

function change2magic(){
    for i in $magic_special_repos
    do
        mm_checkout $i jb-magic
    done

    for i in $magic_common_repos
    do
        mm_checkout $i jellybean
    done
}

function change2cm(){
  for i in $magic_special_repos
  do
      mm_checkout $i jellybean
  done
  
  for i in $magic_common_repos
  do
      mm_checkout $i jb-cm
  done
}

# $1 EG:frameworks/native
# $2 remote name
function mm_fetch(){
  remote_name=""
  repo=$1
  remote_name=$2
  dirPath=$base/$repo
  
  
  if [ "$repo" == "" ]; then
      echo "Error: repo name is empty"
      return $MM_FALSE
  fi
  
  if [ ! -d $dirPath ]; then
      echo "Error: $dirPath not found"
      return $MM_FALSE
  fi
  
  if [ "$remote_name" != "$cm_remote_name" ] && [ "$remote_name" != "$mm_remote_name" ]; then
      echo "Error, remote name should be [$cm_remote_name] or [$mm_remote_name]"
  fi
  
  # got git bare repo name
  # all of them are android_$aaaa.git
  
  #gitName=android_`echo $repo | sed 's/\//_/g'`.git$fetchUrl/$mergeBranch
  
  #case $target in
  #"CyanogenMod")
  #    echo " CyanogenMod"
  #    fetchUrl=$cm_base_url/$gitName
  #    ;;
  # "MagicMod")
  #    echo "MagicMod"
  #    fetchUrl=$mm_base_url/$gitName
  #    ;;
  #*)
  #    echo " default"
  #    fetchUrl=""
  #    ;;
  # esac
  # 
  # if [ "$fetchUrl" == "" ]; then
  #    echo "Error: fetch url not found"
  #    return $MM_FALSE
  # fi
   
   echo "Fetch <$repo> from remote <$remote_name>"
   
   cd $dirPath
   
   git fetch $remote_name
}

# $1 CyanogenMod or MagicMod
# $2 EG:frameworks/native
# $3 branch EG: jellybean-stable
function mm_merge(){
  target=$1
  repo=$2
  mergeBranch=$3
  dirPath=$base/$repo
  remote_name=""
  
  if [ "$repo" == "" ]; then
      echo "Error: argv 2 is null"
      return $MM_FALSE
  fi
  
  if [ ! -d $dirPath ]; then
      echo "Error: $dirPath not found"
      return $MM_FALSE
  fi
  
  if [ "$mergeBranch" == "" ]; then
      echo "Error: branch name is empty"
  fi
  
  # copy from above, ugly
  
  #gitName=android_`echo $repo | sed 's/\//_/g'`.git
  
  case $target in
  "CyanogenMod")
      #echo " CyanogenMod"
      remote_name=$cm_remote_name
      ;;
   "MagicMod")
      #echo "MagicMod"
      remote_name=$mm_remote_name
      ;;
  *)
      #echo " default"
      remote_name=""
      ;;
   esac
   
   if [ "$remote_name" == "" ]; then
      echo "Error: remote name not found"
      return $MM_FALSE
   fi
   
   cd $dirPath
   
   echo "Merge <$repo> current branch into <$remote_name/$mergeBranch>"
   
   git merge $remote_name/$mergeBranch
   
   #ret=`git merge $remote_name/$mergeBranch`
   #return $ret   
}

# $1 the target name, CyanogenMod or MagicMod
# $2 the repo name, EG: frameworks/native
# $3 the action name, should be [AddRemote] or [RmRemote]
function mm_remote() {
  target=$1
  repo=$2
  action=$3
  dirPath=$base/$repo
  fetchUrl=""
  
  if [ "$repo" == "" ]; then
      echo "Error: argv 2 is null"
      return $MM_FALSE
  fi
  
  if [ ! -d $dirPath ]; then
      echo "Error: $dirPath not found"
      return $MM_FALSE
  fi
  
  if [ "$action" == "" ]; then
      echo "Error: Action not fould"
      return $MM_FALSE
  fi
  
  # got git bare repo name
  # all of them are android_$aaaa.git
  
  gitName=android_`echo $repo | sed 's/\//_/g'`.git
  
  case $target in
  "CyanogenMod")
      #echo " CyanogenMod"
      fetchUrl=$cm_base_url/$gitName
      ;;
   "MagicMod")
      #echo "MagicMod"
      fetchUrl=$mm_base_url/$gitName
      ;;
  *)
      #echo " default"
      fetchUrl=""
      ;;
   esac
   
   if [ "$fetchUrl" == "" ]; then
      echo "Error: fetch url not found"
      return $MM_FALSE
   fi
   
   cd $dirPath
   
   case $action in
   "AddRemote")
       case $target in
       "CyanogenMod")
           if git remote | grep $cm_remote_name; then
               git remote rm $cm_remote_name
           fi
           echo "Add <$repo> remote [$cm_remote_name] for [$fetchUrl]"
           git remote add $cm_remote_name $fetchUrl
           ;;
       "MagicMod")
           if git remote | grep $mm_remote_name ;  then
               git remote rm $mm_remote_name
           fi
           echo "Add <$repo> remote [$mm_remote_name] for [$fetchUrl]"
           git remote add $mm_remote_name $fetchUrl
           ;;
       *)
           echo "Error invilid traget name, should [CyanogenMod] or [MagicMod]"
           ;;
       esac
       ;;
   "RmRemote")
       case $target in 
       "CyanogenMod")
           git remote rm $cm_remote_name
           ;;
       "MagicMod")
           git remote rm $mm_remote_name
           ;;
       *)
           echo "Error invilid traget name, should [CyanogenMod] or [MagicMod]"
           ;;
       esac
       ;;
   *)
       echo "Error invilid action, should [AddRemote] or [RmRemote]"
       ;;
   esac
   
   fetchUrl=""
}

function addCmRemote(){
  for i in $magic_special_repos $magic_common_repos
  do
      mm_remote CyanogenMod $i AddRemote
  done
}

function fetchCmRepo(){
  change2cm
  
  for i in $magic_special_repos $magic_common_repos
  do
      mm_fetch $i $cm_remote_name
  done
}

function mergeCmRepo(){
  change2cm
  
  for i in $magic_special_repos $magic_common_repos
  do
      mm_merge CyanogenMod $i $cm_cur_branch
  done
}




cmd=$1
brancName=$2
case $cmd in
"checkout")
    case $brancName in
    "MagicMod")
        change2magic
        ;;
    "CyanogenMod")
        change2cm
        ;;
    *)
        echo "Error, please choose the branch name [CyanogenMod] or [MagicMod] "
        #return $MM_FALSE
       ;;
    esac
    ;;
"sync")
    case $brancName in
    "MagicMod")
        echo "not support now"
        ;;
    "CyanogenMod")
        addCmRemote
        fetchCmRepo
        mergeCmRepo
        ;;
    *)
        echo "Error, please choose the branch name [CyanogenMod] or [MagicMod] "
        #return $MM_FALSE
       ;;
    esac
    ;;
*)
    echo "Use cmd [checkout]/[sync] <brancName>"
    ;;
esac
        