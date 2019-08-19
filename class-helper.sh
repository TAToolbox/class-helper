#!/bin/bash

##############################
#  Class Related Directories #
##############################

# Lesson Plans Directory location
DATAVIZ=~Path/to/master/lesson/plans
# Class Repo Directory
CLASSREPO=~Documents/Test

###############################
#        Shhhh Commands       #
###############################

pushd () {
    command pushd "$@" > /dev/null
}

popd () {
    command popd "$@" > /dev/null
}

###############################
#        Git Handling         #
###############################

# Check repo changes before doing anything
function gitchecker () {
   echo "Checking status of Repositories"
   pushd $DATAVIZ; diffchecker "Lesson Plan"; 
   #pushd $CLASSREPO; diffchecker "Class Repo"; 
   
}

# Quietly check for differences in local and remote repos
function diffchecker () {
   if [[ `git diff HEAD origin/master` ]]; then
      echo "$1 is up to date"
      
   else
      # Changes
      read -r -p "$1 has changes, pull down changes? [Y]/N: " lessonpull

      case $lessonpull in
         [Nn]* )
         ;;
         [Yy]* | *) 
            git pull -q origin master;      
         ;;
      esac
   fi
}


################################
#       Meat and Potatoes      #
################################

# Prompt for weekly topic and pass 
function topicfind () {
   pushd $CLASSREPO/Class-MW-Rice-Cookers
   # Topic prompt
   read -r -p "What's the topic this week?: "  topic;
   topicpath="`find -L $DATAVIZ/01-Lesson-Plans -maxdepth 1 -iname *$topic* -type d -print -quit`" 
   
   # Handler for errors or spelling
   if test -z "$topicpath"; then
      echo  $topic lesson not found, try again
      topicfind $1
   else
      basetopic=$(basename $topicpath)
      $1
   fi
}

function copy2class () {
   # Output directory name and confirm prompt
   read -r -p "$(echo $basetopic)? [Y]/N: " input 
   case $input in
      [Nn]* ) 
         topicfind copy2class;;
      [Yy]* | * ) 
         echo "Copying 01-Lesson-Plans/$basetopic --> /Class-MW-Rice-Cookers/$basetopic";
   
         cp -r $topicpath $CLASSREPO/Class-MW-Rice-Cookers;
         saveyourself;
         dailysetup;;
   esac
   
}

############################
#  Prevent Dumb Mistakes   #
############################

# Remove instruction-team only materials
function saveyourself () {
   pushd $CLASSREPO/Class-MW-Rice-Cookers/$basetopic
   echo 'Cleaning up'
   rm -r -f readme.md VideoGuide.md Supplemental
   for x in 1 2 3
      do
      :
      rm $x/TimeTracker.xlsx $x/LessonPlan.md
      done
   echo "Creating weekly .gitignore"
   find 1 2 3 -maxdepth 3 -type d | sort | grep -v \"un\|Reg\" > .gitignore
   
}

#######################
#  Homework Handling  #
#######################

function homeworkhandler () {
   read -r -p "Do you want to add the homework? [Y]/N " homework   
   case $homework in
      [Nn]* ) 
         echo "Have a great class!";;
      [Yy]* | * )
         echo "Copying 02/Homework/$basetopic --> /HW/$basetopic"
         mkdir $CLASSREPO/HW/$basetopic
         cp -r $DATAVIZ/02-Homework/$basetopic/Instructions/* $CLASSREPO/HW/$basetopic
         pushd $CLASSREPO/HW/$basetopic
         echo "Cleaning up"
         rm -r -f Solutions gradingrubric.md gradingrubrics      
         ;;
   esac
   echo "Have a great day!"
}


##############################
#        Daily Setup         #
##############################

function dailysetup () {
   pushd $CLASSREPO/Class-MW-Rice-Cookers/$basetopic
   echo "Working from $basetopic directory"
   echo "Which Lecture Day?"
   read -r -p "[1]  [2]  [3] : " day
   read -r -p "Mass Comment Unsolved? [Y]/N: " massconfirm
   case $massconfirm in
      [nN]* )
         echo "Moving to Activity Pusher";
         activitypusher;;
      [Yy]* | * )
         echo "Commenting $basetopic Day $day Activities"
         masspush
         echo "Done"
         activitypusher;;
   esac
   
}

function masspush () {
   sed -i "/^.*Solved/! s/^$day/#$day/" $CLASSREPO/Class-MW-Rice-Cookers/$basetopic/.gitignore
}

##############################
#      Activity Pusher       #
##############################

function activitypusher () {
   pushd $CLASSREPO/Class-MW-Rice-Cookers/$basetopic
   linecount=0
   for line in $(cat .gitignore)
   do
   ((linecount++))
      if [[ $line =~ ^$day.*Solved ]]; then
         read -r -p "$(echo $line | cut -d'/' -f 3)? [Y]/N: " linecheck
         case $linecheck in
            [Nn]* ) 
               continue;;
            [Yy] | * )
               sed -i "$linecount {s/^/#/}" .gitignore
               echo "Commented $line"
               continue;;
         esac
      else
         continue
      fi
   done
   echo "No more lessons in Lecture $day"
   # Test for homework directory, if false trigger homework handler
   if [ -d "$CLASSREPO/HW/$basetopic" ]; then
      echo "Have a great day!"
   else
      homeworkhandler;
   fi
}


##############################
#     Use Case Prompt        #
##############################

# Allow for different use cases
# Weekly Class Setup, Homework, etc...

echo -e "What do you want to do?"
read -r -p "[1]-Weekly Setup [2]-Homework [3]-Activities : " usecase

case $usecase in
   [1] ) 
      gitchecker;
      topicfind copy2class;;
   [2] ) 
      gitchecker;
      topicfind homeworkhandler;;
   [3] )
      gitchecker;
      topicfind dailysetup;;
   * )
      echo "Please choose a valid selection" 
      helper;;
esac