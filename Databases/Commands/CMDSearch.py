#!/usr/bin/env python3

import sqlite3
import difflib
import argparse
import sys

#use difflib.get_close_match() to get close matches for the search term
#interact with sqlite database

#Text formatting
green = "\033[32m"
red = "\033[31m"
bold = "\033[1m"
dim = "\033[2m"
reset = "\033[0m"

try:
    con = sqlite3.connect('HackzDBNH.db')
    cur = con.cursor()
except:
    print("There was an issue connecting to the database, is 'HackzDBNH.db' in the same directory as the script?")
    sys.exit(1)

#Arguments
parser = argparse.ArgumentParser()

parser.add_argument('-s', '--search', help="Search entire database") #messing action=...
parser.add_argument('-p', '--program', help="Search programs database") #messing action=...
parser.add_argument('-c', '--command', help="Search for commands") #messing action=...
parser.add_argument('-a', '--attack', help="Search attack database for description") #messing action=...
parser.add_argument('-t', '--target', help="Search the attacks by target of the attack") #messing action=...

args = parser.parse_args()

#select the full 
def search_term():
    string = ' '.join(str(x) for x in sys.argv[2:])
    return string

#program, command, attack, target (in Attks), search (includes tag)

if sys.argv[1].lower() == "search":
    print('later')
elif sys.argv[1].lower() == "program":
    #searches for programs description 
    cur.execute("SELECT FROM Progs WHERE description LIKE {};".format(sys.argv[1]))
    print('later')
elif sys.argv[1].lower() == "command":
    print('later')
elif sys.argv[1].lower() == "attack":
    print('later')
elif sys.argv[1].lower() == "target":
    print('later')
else:
    print("Please submit one of the following actions in the command: search, program, command, attack, or target ")
