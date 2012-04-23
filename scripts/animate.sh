#!/bin/sh

#**************************************************************************
# Animate a blender file from the command line
# Version 2
# 2012-04-23
# Xotic750
# This release may be used under the terms of the license: GPLv2
# http://www.gnu.org/licenses/gpl-2.0.html
#**************************************************************************

BLENDS="$PWD/sprite_source/blender/"
RENDERED="$PWD/sprite_source/blender/rendered"

# Exit codes
# An exit status of zero indicates success, and a nonzero value indicates failure.
E_USAGE=1
E_SOURCE=2
E_DESTINATION=3
E_PARAMETERS=4
E_GIMP=5
E_BLENDS=6
E_ENGINES=7
E_RENDERED=8
E_BLENDFILE=9
E_RM_DST=10
E_MK_DST=11
# Internal variable for holding the model name
T_MODEL=$1

# Function: func_param_check
# Parameters: <line number> <function name> <param count> <min params>
function func_param_check()
{
    if [ $# -lt 4 ]; then
        echo -e "$(date +%s):$0:$T_MODEL:func_param_check::Parameter count ($#) but must be (4)\n" 1>&2
        exit $E_PARAMETERS
    fi

    if [ $3 -lt $4 ]; then
        echo -e "$(date +%s):$0:$T_MODEL:$2:$1:Parameter count ($3) but must be ($4)\n" 1>&2
        exit $E_PARAMETERS
    fi
}

#**************************************************************************
# Function: func_strip_trailing_slashes
# Parameters: <line number> <var pointer> <path string>
#**************************************************************************
function func_strip_trailing_slashes()
{
    func_param_check $1 $FUNCNAME $# 3
    local PATTERN='^.*[^/]'
    local __RESULTVAR=$2
    local STRIPPED_SLASHES=$3
    [[ $STRIPPED_SLASHES =~ $PATTERN ]]
    STRIPPED_SLASHES=${BASH_REMATCH[0]}

    if [[ "$__RESULTVAR" ]]; then
        eval $__RESULTVAR="'$STRIPPED_SLASHES'"
    else
        echo "$STRIPPED_SLASHES"
    fi
}

#**************************************************************************
# Function: func_add_trailing_slash
# Parameters: <line number> <var pointer> <path string>
#**************************************************************************
function func_add_trailing_slash()
{
    func_param_check $1 $FUNCNAME $# 3
    local __RESULTVAR=$2
    local ADDED_SLASH="$3/"

    if [[ "$__RESULTVAR" ]]; then
        eval $__RESULTVAR="'$ADDED_SLASH'"
    else
        echo "$ADDED_SLASH"
    fi
}

#**************************************************************************
# Function: func_format_path
# Parameters: <line number> <var pointer> <path string>
#**************************************************************************
function func_format_path()
{
    func_param_check $1 $FUNCNAME $# 3
    local __RESULTVAR=$2
    local FORMATTED_PATH

    func_strip_trailing_slashes $LI-nNENO FORMATTED_PATH $3
    func_add_trailing_slash $LINENO FORMATTED_PATH $FORMATTED_PATH

    if [[ "$__RESULTVAR" ]]; then
        eval $__RESULTVAR="'$FORMATTED_PATH'"
    else
        echo "$FORMATTED_PATH"
    fi
}

#**************************************************************************
# Function: func_concat_path
# Parameters: <line number> <var pointer> <path string 1> <path string 2>
#**************************************************************************
function func_concat_path()
{
    func_param_check $1 $FUNCNAME $# 4
    local __RESULTVAR=$2
    local CONCATTED_PATH

    func_format_path $LINENO CONCATTED_PATH $3
    CONCATTED_PATH=$CONCATTED_PATH$4

    if [[ "$__RESULTVAR" ]]; then
        eval $__RESULTVAR="'$CONCATTED_PATH'"
    else
        echo "$CONCATTED_PATH"
    fi
}

#**************************************************************************
# Function: func_exit_on_error
# Parameters: <line number> <exit check number> <error text> [<user exit number>]
#**************************************************************************
function func_exit_on_error()
{
    func_param_check $1 $FUNCNAME $# 3

    if [ $2 -ne 0 ]; then
        echo -e "$(date +%s):$0:$T_MODEL:::$3\n" 1>&2
        if [ $# -gt 3 ]; then
            exit $4
        else
            exit $2
        fi
    fi
}

#**************************************************************************
# Function: func_remove
# Parameters: <line number> <src files> [<user exit number>]
#**************************************************************************
function func_remove()
{
    func_param_check $1 $FUNCNAME $# 2
    func_echo_spin $LINENO $V_NOISY "Removing: $2"
    rm --preserve-root -rf $SWITCH_V $2
    local EXIT_VAL=$?
    local ERR_TXT="Failed to remove:$2"

    if [ $# -gt 2 ]; then
        func_exit_on_error $LINENO $EXIT_VAL "$ERR_TXT" $3
    else
        func_exit_on_error $LINENO $EXIT_VAL "$ERR_TXT"
    fi
}

#**************************************************************************
# Function: func_mkdir
# Parameters: <line number> <directory> [<user exit number>]
#**************************************************************************
function func_mkdir()
{
    func_param_check $1 $FUNCNAME $# 2
    if [ ! -d $2 ]; then
        func_echo_spin $LINENO $V_NOISY "Creating directory: $2"
        mkdir $SWITCH_V $2
        local EXIT_VAL=$?
        local ERR_TXT="Failed to create directory:$2"

        if [ $# -gt 2 ]; then
            func_exit_on_error $LINENO $EXIT_VAL "$ERR_TXT" $3
        else
            func_exit_on_error $LINENO $EXIT_VAL "$ERR_TXT"
        fi
    fi
}

#**************************************************************************
# Function: func_chkdir
# Parameters: <line number> <directory> <error text> [<user exit number>]
#**************************************************************************
function func_chkdir()
{
    func_param_check $1 $FUNCNAME $# 2
    if [ ! -d $2 ]; then
        if [ $# -gt 3 ]; then
            func_exit_on_error $LINENO 1 "$3" $4
        else
            func_exit_on_error $LINENO 1 "$3"
        fi
    fi
}

# Check that a model name has been provided as a parameter to the script
if [ $# -eq 0 ]; then
    func_exit_on_error $LINENO 1 "Usage:$0 <model-name>" $E_USAGE
fi

# Render the model
func_concat_path $LINENO BLENDFILE $BLENDS $1.blend $E_BLENDFILE

func_concat_path $LINENO DST $RENDERED $1 $E_DST
func_remove $LINENO $DST $E_RM_DST
func_mkdir $LINENO $DST $E_MK_DST
func_chkdir $LINENO $DST "DST directory does not exist:$DST" $E_DST

blender -b $BLENDFILE -a
