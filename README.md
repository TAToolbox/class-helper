# Class Helper

## Setup:

Change the class related paths to your local paths for corresponding directories

```bash
##############################
#  Class Related Directories #
##############################

# Lesson Plans Directory location
DATAVIZ=~Path/to/master/lesson/plans #<--- ~/Documents/Bootcamp-Lesson-Plans
# Class Repo Directory
CLASSREPO=~Path/to/class/repo #<--- ~/Documents/UNIVERSITY201908...
CLASSDAY=/MW #/TTH #<--- Your class day folder
```

Be sure to change your class day path as well.

## Running the script

Once you have completed the setup, navigate to the folder in bash and type `class-helper.sh` and that's it. Follow the prompts and the script will handle the rest.

## Tips to make it even easier

Add the following to your .bashrc file to run the script from anywhere with an alias.

```bash
alias classhelper='pushd ~/path/to/class-helper && sh class-helper.sh && popd'
```

Reload bash and you're all set.

## Known Bugs

[![Github Issues](https://img.shields.io/github/issues/TAToolbox/class-helper)](https://github.com/TAToolbox/class-helper/issues)

None that I know of at the moment!
