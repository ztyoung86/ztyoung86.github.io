#!/bin/bash

HEXO_DIR="hexo-dir"

# init the hexo folder
rm -rf $HEXO_DIR
hexo init $HEXO_DIR
cd $HEXO_DIR

# link scaffolds and source
rm -rf scaffolds
ln -s ../scaffolds scaffolds
rm -rf source
ln -s ../source source

# get theme
#git clone https://github.com/ztyoung86/hexo-theme-next.git themes/next
git clone https://github.com/theme-next/hexo-theme-next themes/next

# bakup and link config
mv _config.yml _config.yml.bak
ln -s ../_config.yml _config.yml

# install required packages
npm install
## git
npm install hexo-deployer-git --save
## RSS
npm install hexo-generator-feed --save
# Local Search
npm install hexo-generator-search --save

# link deploy script
ln -s ../deploy.sh deploy.sh

# force push
#git push -u https://github.com/ztyoung86/ztyoung86.github.io.git HEAD:hexo --force


#### Unbuntu 16.04 LTS ####
# hexo: 3.2.2
# hexo-cli: 1.0.2
# os: Linux 4.4.0-34-generic linux x64
# http_parser: 2.7.0
# node: 6.4.0
# v8: 5.0.71.60
# uv: 1.9.1
# zlib: 1.2.8
# ares: 1.10.1-DEV
# icu: 57.1
# modules: 48
# openssl: 1.0.2h
