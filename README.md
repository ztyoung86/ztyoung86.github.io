## To do
只保留 source, scaffolds，_config.yml 以及依赖包的记录（如package.json), themes 和 hexo 包在本地通过脚本安装。

## Troubleshooting
### server failed
卸载 hexo 和 hexo-cli，重新安装。

### server 起来后显示错误
查看 requirements 和 package.json，安装缺失的包。

### 以上都不行
 1. hexo init 一个新目录。
 2. 把 source 和 scaffolfs 目录复制过去。
 3. git clone 自己的 hexo-theme-next.git (submodule)。
 4. 修改站点的_config.yml
 5. `git push -u https://github.com/ztyoung86/ztyoung86.github.io.git HEAD:hexo --force`
