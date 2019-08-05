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
   echo "Checking for changes to Lesson Plan"
   pushd $DATAVIZ; diffchecker "Lesson Plan"; popd
   pushd $CLASSREPO; diffchecker "Class Repo"; popd
}

# Quietly check for differences in local and remote repos
function diffchecker () {
   if [[ `git diff HEAD origin/master` ]]; then
      echo $1 is up to date
   else
      # Changes
      read -r -p "$1 has changes, pull down changes? [Y/N]" lessonpull
      case $lessonpull in
         [Yy]* ) 
            git pull -q origin master;      
         ;;
         [Nn]* )
            topicfind;;
         * )
            exit;;
      esac
   fi
}


################################
#       Meat and Potatoes      #
################################

# Prompt for weekly topic and pass 
function topicfind () {
   # Topic prompt
   read -r -p "What's the topic this week?: " topic        
   topicpath="`find -L $DATAVIZ/01-Lesson-Plans -maxdepth 1 -iname *$topic* -type d -print`" 
   
   # Handler for errors or spelling
   if test -z "$topicpath"; then
      echo "$topic lesson not found, try again"
      topicfind $1
   else
      basetopic=$(basename $topicpath)
      $1
   fi
}

function copy2class () {
   # Output directory name and confirm prompt
   read -r -p "$(echo $basetopic)? [Y/N] " input 
   case $input in
      [Yy]* ) 
         echo "Copying 01-Lesson-Plans/$basetopic --> $CLASSREPO";
         cp -r $topicpath $CLASSREPO;
         saveyourself
         homeworkhandler;;
      [Nn]* ) 
         topicfind;;
      * ) 
         exit;;
   esac
}

############################
#  Prevent Dumb Mistakes   #
############################

# Remove instruction-team only materials
function saveyourself () {
   pushd $CLASSREPO/$basetopic
   echo Cleaning up
   rm -r -f readme.md VideoGuide.md Supplemental
   for x in 1 2 3
      do
      :
      rm $x/TimeTracker.xlsx $x/LessonPlan.md
      done
   echo "Creating weekly .gitignore"
   find 1 2 3 -maxdepth 3 -type d | sort | grep -v \"un\|Reg\" > .gitignore
   popd
}

#######################
#  Homework Handling  #
#######################

function homeworkhandler () {
   read -r -p "Do you want to add the homework? [Y/N] " homework   
   case $homework in
      [Yy]* )
         echo "Copying 02/Homework/$basetopic --> /HW/$basetopic"
         mkdir $CLASSREPO/HW/$basetopic
         cp -r $DATAVIZ/02-Homework/$basetopic/Instructions/* $CLASSREPO/HW/$basetopic
         pushd $CLASSREPO/HW/$basetopic
         echo "Cleaning up"
         rm -r -f Solutions gradingrubric.md gradingrubrics      
         popd;;
      [Nn]* ) 
         echo "Have a great class!";;
      * ) 
         exit;;
   esac
}


##############################
#    Activity Pushing        #
##############################

# Currently Set up to push out all unsolved
# Single Activities is on the docket
function activitypusher () {
   pushd $CLASSREPO/$basetopic
   echo Working from $basetopic directory
   echo "Which Lecture Day?"
   echo "[1]  [2]  [3]  [4]: all" 
   read -r day
   case $day in
      [4] )
         masspush
         ;;
       *)
         echo "Commenting $basetopic Day $day Activities"
         masspush
         echo "Done"
         echo "Have a great class!"
         ;;
   esac
      
}

function masspush () {
   sed -i "/^.*Solved/! s/^$day/#$day/g" $CLASSREPO/$basetopic/.gitignore
}

##############################
#     Use Case Prompt        #
##############################

# Allow for different use cases
# Weekly Class Setup, Homework, etc...

echo "What do you want to do?"
echo "[1]: Weekly Setup [2]: Homework [3]: Push Activities"
read -r usecase
case $usecase in
   [1] ) 
      gitchecker;
      topicfind copy2class;;
   [2] ) 
      gitchecker;
      topicfind homeworkhandler;;
   [3] )
      gitchecker;
      topicfind activitypusher;;
   * )
      echo "Please choose a valid selection" 
      class-helper.sh;;
esac
