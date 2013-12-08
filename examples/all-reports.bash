#!/bin/bash

export PATH=~/multidistrotools:$PATH
export MDT_SCRIPTSDIR=~/multidistrotools/scripts

UBUNTUBUGSEXTENDED=--ubuntu-bugs-extended
UBUNTUBUILDSTATUS=--ubuntu-build-status 

DIR=$(mktemp -d /tmp/mdt.XXXXXX)
DESTDIR=/home/lucas/public_html/versions/

if [ ! -d $DESTDIR ]; then
	echo "$DESTDIR doesn't exist, edit the script or create."
	exit 1
fi

# because we will generate some temporary files
cd $DIR

# Update our package lists (Packages and Sources files)
if [ ! -d $HOME/.multidistrotools/sid ]; then
	mdt dist-create sid http://ftp.debian.org/debian unstable main contrib non-free
fi
if [ ! -d $HOME/.multidistrotools/edgy ]; then
	mdt dist-create edgy http://archive.ubuntu.com/ubuntu edgy main restricted universe multiverse
fi
if [ ! -d $HOME/.multidistrotools/experimental ]; then
	mdt dist-create experimental http://ftp.debian.org/debian experimental main contrib non-free
fi
if [ ! -d $HOME/.multidistrotools/breezy ]; then
	mdt dist-create breezy http://archive.ubuntu.com/ubuntu breezy main restricted universe multiverse
fi
if [ ! -d $HOME/.multidistrotools/debian-multimedia ]; then
	mdt dist-create debian-multimedia http://mirrors.ecology.uni-kiel.de/debian/debian-multimedia sid main
fi

for i in sid edgy dapper experimental debian-multimedia; do
	mdt dist-apt-get $i -q update
done

# Get popcon results
mdt popcon > popcon_packages
mdt bin2src < popcon_packages > popcon_sources

# Lists versions in Debian and Ubuntu
mdt compare-versions sid edgy > du-versions

# Get the MOTUNotes
mdt motunotes > motunotes

# Get sistpoty's results
if [ -f /home/sistpoty/merge_offline/mergebase_yappy.py ]; then
  python /home/sistpoty/merge_offline/mergebase_yappy.py > mergebaseyaml
  mdt mergelist2comments < mergebaseyaml > mergenotes
fi

# Get the bug list
wget http://qa.debian.org/data/ddpo/results/bugs.txt

### REPORTS
# Generate a report about universe/multiverse packages
mdt dist-grep-dctrl-sources edgy -F Section -s Package -n universe > universepkg
mdt dist-grep-dctrl-sources edgy -F Section -s Package -n multiverse > multiversepkg
mdt list_union universepkg multiversepkg > versepkg
mdt filter versepkg < du-versions > verse-versions
mdt sort_with popcon_sources < verse-versions > verse-versions-sorted
# gen reports

####################################################
# Universe reports
mdt versions2html --debian-links --ubuntu-links --titleA Debian --titleB Ubuntu --exclude notinB --exclude sameversion --description "Packages from Universe and Multiverse with a different version in Debian" --comment-title "0,MOTUNotes" --comment-uri "0,motunotes" --comment-title "1,Merges" --comment-uri "1,mergenotes" --debian-bugs "bugs.txt" < verse-versions-sorted > $DESTDIR/unimultiverse-all.html

mdt versions2html --debian-links --ubuntu-links --titleA Debian --titleB Ubuntu --exclude notinB --exclude notinA --exclude outdatedinA --exclude sameversionbutlocalinA --exclude sameversionbutlocalinB --exclude sameversionbutlocalinboth --exclude sameversion --description "Packages from Universe and Multiverse with a different version in Debian" --comment-title "0,MOTUNotes" --comment-uri "0,motunotes" --comment-title "1,Merges" --comment-uri "1,mergenotes" --debian-bugs "bugs.txt" < verse-versions-sorted > $DESTDIR/unimultiverse-outdated-ubuntu.html

mdt versions2html --debian-links --ubuntu-links --titleA Debian --titleB Ubuntu --exclude notinB --exclude outdatedinB --exclude sameversionbutlocalinA --exclude sameversion --description "Packages from Universe and Multiverse with a different version in Debian" --comment-title "0,MOTUNotes" --comment-uri "0,motunotes" --comment-title "1,Merges" --comment-uri "1,mergenotes" --debian-bugs "bugs.txt" < verse-versions-sorted > $DESTDIR/unimultiverse-outdated-debian.html

##################################################
# Generate a report about all of Ubuntu and Debian
mdt versions2html --debian-links --ubuntu-links --titleA Debian --titleB Ubuntu  --exclude sameversion --description "All packages in Debian and Ubuntu"  < du-versions > $DESTDIR/all-packages.html

##################################################
# My own private list of packages
if [ -f $HOME/.mypkglist ]; then
  mdt filter $HOME/.mypkglist < versepkg > my-versepkg
  mdt filter my-versepkg < du-versions > my-verse-versions
  mdt sort_with popcon_sources < my-verse-versions > my-verse-versions-sorted
  mdt versions2html --debian-links --ubuntu-links --titleA Debian --titleB Ubuntu --exclude notinB --exclude sameversion --description "Packages from Universe and Multiverse with a different version in Debian" --comment-title "0,MOTUNotes" --comment-uri "0,motunotes" --comment-title "1,Merges" --comment-uri "1,mergenotes" --debian-bugs "bugs.txt" $UBUNTUBUGSEXTENDED $UBUNTUBUILDSTATUS < my-verse-versions-sorted > $DESTDIR/lucas.html
fi

##################################################
# Ruby-related packages

if [ -e /home/lucas/moturuby/getsrcpkgs.bash ]; then
  /home/lucas/moturuby/getsrcpkgs.bash > rubysources
fi
mdt filter rubysources < du-versions > ruby-versions
mdt sort_with popcon_sources < ruby-versions > ruby-versions-sorted
mdt versions2html --debian-links --ubuntu-links --titleA Debian --titleB Ubuntu --description "Ruby-related packages in Debian and Ubuntu" --comment-title "0,MOTUNotes" --comment-uri "0,motunotes"  --comment-title "1,Merges" --comment-uri "1,mergenotes" --debian-bugs "bugs.txt" $UBUNTUBUGSEXTENDED $UBUNTUBUILDSTATUS < ruby-versions-sorted > $DESTDIR/ruby.html

##################################################
# Ruby-related packages

if [ -e /home/lucas/jabber/getsrcpkgs.bash ]; then
  /home/lucas/jabber/getsrcpkgs.bash > jabsources
fi

mdt filter jabsources < du-versions > jab-versions
mdt sort_with popcon_sources < jab-versions > jab-versions-sorted
mdt versions2html --debian-links --ubuntu-links --titleA Debian --titleB Ubuntu --description "Jabber-related packages in Debian and Ubuntu" --comment-title "0,MOTUNotes" --comment-uri "0,motunotes"  --comment-title "1,Merges" --comment-uri "1,mergenotes" --debian-bugs "bugs.txt" $UBUNTUBUGSEXTENDED $UBUNTUBUILDSTATUS < jab-versions-sorted > $DESTDIR/jabber.html

##################################################
# Experimental vs Unstable
mdt compare-versions sid experimental > du-exp-unst-versions
mdt versions2html --debian-links --titleA Unstable --titleB Experimental --exclude notinB --description "Packages in Debian Experimental compared to their versions in Debian Unstable" < du-exp-unst-versions > $DESTDIR/unstable-experimental.html

##################################################
# Debian Multimedia stuff
mdt compare-versions debian-multimedia edgy > debmulti-versions
mdt versions2html --titleA DebianMultimedia --titleB Edgy --exclude notinA --description "Packages in Debian Multimedia compared to their versions in Edgy" < debmulti-versions > $DESTDIR/debian-multimedia.html

##################################################
# write an header
cat <<EOF > $DESTDIR/HEADER.html
<style>
body {
	font-family: sans-serif;
	font-size: small;
}
</style>
<h1>Package versions in Ubuntu and Debian</h1>
<p>Those pages allows to easily compare the state of packages in both Ubuntu and Debian.</p>
<ul>
<li>They are generated with <a href="https://wiki.ubuntu.com/MultiDistroTools">MultiDistroTools (mdt)</a>. Don't hesitate to improve those tools !</li>
<li>Every six hours (cron entry is 42 */6 * * *)</li>
<li>The lists are generally sorted using <a href="http://popcon.debian.org/">Debian's popcon results</a> (since Ubuntu's popcon is <a href="http://bugzilla.ubuntu.com/show_bug.cgi?id=12761">currently broken</a>), allowing you to know which packages are the most important ones.</li>
<li>If you want to monitor another set of packages, just tell me (or better, give me the mdt script for it ;)</li>
<li>The MOTUNotes comments come from <a href="https://wiki.ubuntu.com/MOTUNotes">the MOTUNotes wiki page</a></li>
<li>The Merges comments come from <a href="http://tiber.tauware.de/~sistpoty/MoM/index.py?state=new">sistpoty's Merge lookup page</a></li>
<li>If you have an idea to make it more compact, just tell me :-)</li>
</ul>
<p style="padding-left: 40em;">- <a href="https://launchpad.net/people/nussbaum">Lucas</a></p>
EOF

# clean up
rm -rf $DIR
