#!/bin/bash
#
# updatesoa.sh - a simple script to update BIND SOA serial numbers
#
# Copyright (c) 2015 Gabriel M. O'Brien
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.
#

SOA=/etc/bind/SOA

[ -f $SOA ] || exit 65

oldsn=$( awk '/Serial/ { print $1 };' $SOA )
olddate=$( echo $oldsn | cut -b1-8 )
datestr=$( date +%Y%m%d )

# show current serial
printf 'Current DNS serial:\t%s\n' $oldsn

# if the date has changed reset the $inc to 00
if [ "$datestr" != "$olddate" ]; then
  inc=00
else
  # this strips the leading zero from the inc digits if present and increments
  inc=$( expr `echo $oldsn | rev | cut -b1-2 | rev` + 0 ) ; ((inc++))
fi

# if the increment is 99 then exit, the serial can not be more than 10 digits
if [ "$inc" == "100" ]; then
  echo "Current serial is 99, unable to increment automatically. Exiting."
  exit 1
fi

# now create the new serial
newsn=$( printf '%s%02d' $datestr $inc )
printf 'New DNS serial:\t\t%s\n' $newsn

# and update the SOA record
cp -f $SOA ${SOA}.old && \
  sed "s/${oldsn}/${newsn}/" ${SOA}.old > $SOA
printf 'SOA updated.\n'

