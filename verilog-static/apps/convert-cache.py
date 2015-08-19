#! /usr/bin/env python

import os

try:
  os.mkdir('dump')
  os.mkdir('vmh')
except:
  pass

bin_dir = '.'
#bin_dir = '/ufs/brg/install/stow-pkgs/maven/bin'
files = os.listdir( bin_dir )
bins = []
for f in files:
  if os.path.isfile(f) and ('Makefile' not in f) and ('.' not in f):
    bins += [f]

print bins
for b in bins:
  x = bin_dir + '/' + b
  cmd = ('maven-objdump -DC --disassemble-zeroes --section=.text '
          '--section=.data --section=.sdata --section=.xcpthandler --section=.init '
          '--section=.fini --section=.ctors --section=.dtors --section=.eh_frame '
          '--section=.jcr --section=.sbss --section=.bss --section=.rodata '
          '%s > dump/%s.dump' % (x, b)
        )
  print cmd
  os.system( cmd )

script_dir = '../scripts'
#script_dir = '~/vc/git-brg/micro2012/maven-app-misc/scripts'
dumps = os.listdir('dump')
for d in dumps:
  cmd = 'python ' + script_dir + '/objdump2vmh-cache.py -f dump/%s' % d
  print cmd
  os.system( cmd )
#  cmd = 'python ' + script_dir + '/objdump2vmh.py -f dump/%s' % d
#  print cmd
#  os.system( cmd )

cmd = 'mv dump/*.vmh vmh'
print cmd
os.system( cmd )
