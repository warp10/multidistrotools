#!/usr/bin/python
#
# Changelog:
# * 20060318 - Otavio Salvador <otavio@ossystems.com.br>:
#   - Remove hard-coded user environment

import apt_pkg
import sys
import os

apt_pkg.init()
suite_home="%s/.multidistrotools/%s" % (os.getenv("HOME"), sys.argv[1])
apt_pkg.Config.Set("Dir","%s/" % suite_home)
apt_pkg.Config.Set("Dir::State::status","%s/var/lib/dpkg/status" % suite_home)
cache = apt_pkg.GetCache()
depcache = apt_pkg.GetDepCache(cache)
depcache.Init()
records = apt_pkg.GetPkgRecords(cache)
srcrecords = apt_pkg.GetPkgSrcRecords(cache)

def get_source_pkg(pkg, records, depcache):
        """ get the source package name of a given package """
        version = depcache.GetCandidateVer(pkg)
        if not version:
                return None
        file, index = version.FileList.pop(0)
        records.Lookup((file, index))
        if records.SourcePkg != "":
                srcpkg = records.SourcePkg
        else:
                srcpkg = pkg.Name
        return srcpkg

if len(sys.argv) == 3:
    base = cache[sys.argv[2]]
    print get_source_pkg(base, records, depcache)
elif len(sys.argv) == 2:
    if sys.argv[1] == '--help':
        print('This script gives the source package for the binary package given as\nargument. If no package name is provided, a list of packages read on\nstandard input is used.\nExamples:\n mdt bin2src gnome\n mdt bin2src < pkg_list')
        sys.exit(1)
    for l in sys.stdin.readlines():
        try:
            base = cache[l.rstrip()]
            print get_source_pkg(base, records, depcache)
        except KeyError:
            print l.rstrip()
