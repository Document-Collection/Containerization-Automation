# Containerization-Automation

[![Documentation Status](https://readthedocs.org/projects/containerization-automation/badge/?version=latest)](https://containerization-automation.readthedocs.io/zh_CN/latest/?badge=latest) [![standard-readme compliant](https://img.shields.io/badge/standard--readme-OK-green.svg?style=flat-square)](https://github.com/RichardLitt/standard-readme) [![Conventional Commits](https://img.shields.io/badge/Conventional%20Commits-1.0.0-yellow.svg)](https://conventionalcommits.org) [![Commitizen friendly](https://img.shields.io/badge/commitizen-friendly-brightgreen.svg)](http://commitizen.github.io/cz-cli/)

> 容器化与自动化

学习和使用容器和自动化工具

1. `Docker`
2. `Kubernetes`
3. `Jenkins CI`
4. `Travis CI`

## 内容列表

- [背景](#背景)
- [安装](#安装)
- [用法](#用法)
- [主要维护人员](#主要维护人员)
- [参与贡献方式](#参与贡献方式)
- [许可证](#许可证)

## 背景

容器以及自动化工具的出现极大的加快了软件的生产步骤，同时能够有效解决复杂的依赖环境。看了`Docker`和`CI`工具的介绍，好好利用起来能得到一个很棒的开发环境，赶紧动起来!!!

## 安装

需要预先安装以下工具：

```
$ pip install -U Sphinx
$ sudo apt-get install make
```

## 用法

有两种使用方式

1. 在线浏览文档：[Containers and Automation](https://container-automation.readthedocs.io/zh_CN/latest/)

2. 本地生成文档，实现如下：

    ```
    $ git clone https://github.com/zjZSTU/Containerization-Automation.git
    $ cd Containerization-Automation/docs
    $ make html
    ```
    编译完成后进入`docs/build/html`目录，打开`index.html`文件

## 主要维护人员

* zhujian - *Initial work* - [zjZSTU](https://github.com/zjZSTU)

## 参与贡献方式

欢迎任何人的参与！打开[issue](https://github.com/zjZSTU/Container-Automation/issues)或提交合并请求

注意:

* `GIT`提交，请遵守[Conventional Commits](https://www.conventionalcommits.org/en/v1.0.0-beta.4/)规范
* 语义版本化，请遵守[Semantic Versioning 2.0.0](https://semver.org)规范
* `README`编写，请遵守[standard-readme](https://github.com/RichardLitt/standard-readme)规范

## 许可证

[Apache License 2.0](LICENSE) © 2019 zjZSTU
