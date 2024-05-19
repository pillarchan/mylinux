# 04、部署集群-概览

## 1、版本

OceanBase 数据库是阿里巴巴和蚂蚁集团不基于任何开源产品，完全自研的原生分布式关系数据库软件，提供 OceanBase 企业版和 OceanBase 社区版服务。

OceanBase 社区版目前只提供 MySQL 模式租户服务，高度兼容 MySQL 数据库，源代码完全公开，且使用免费。

OceanBase 企业版提供 MySQL 模式和 Oracle 模式租户服务，高度兼容

Oracle/MySQL 数据库，在 OceanBase 社区版的基础上，提供更多高级功能，如

商业特性兼容、图形化管理工具、操作审计、安全加密、高可用扩展等特性。

本手册将主要介绍部署 OceanBase 企业版和 OceanBase 社区版以及部署

**OceanBase 云平台（OceanBase Cloud Platform，OCP）**

**OceanBase 代理服务（ODP） （obproxy）**

**OceanBase 迁移服务（OceanBase Migration Service，OMS）**

**OceanBase 开发者中心（OceanBase Developer Center，ODC）**等。

## 2、部署方式

OceanBase 企业版：

通过 OCP 部署 OceanBase 集群。

通过命令行部署 OceanBase 集群。

OceanBase 社区版：

使用 docker 镜像的方式进行部署 OceanBase 集群。

使用 OBD 部署 OceanBase 集群。

通过 OCP 部署 OceanBase 集群。

在 Kubernetes 集群中部署 OceanBase 集群。

## 3、适用场景

### OceanBase 企业版：

对于生产环境，建议使用 OCP 部署 OceanBase 集群。具体操作请参见 使用 OCP 创建 OceanBase 集群。

对于非生产环境并且未安装 OCP 的场景，可以通过命令行部署 OceanBase 集群。

具体操作请参见 快速体验 OceanBase 数据库。

### OceanBase 社区版：

对于**非原生支持的操作系统**（比如 MAC 和 Windows），**建议使用 Docker 镜像的方式进行部署**。具体操作参见 快速体验 OceanBase 数据库 一文中 方案三：部署OceanBase 容器环境。

对于**原生支持的操作系统**（Linux 系列，具体见支持的操作系统列表），**建议使用OBD 进行一键部署**。具体操作参见 快速体验 OceanBase 数据库 一文中 方案一：部署 OceanBase 演示环境。

对于线下环境，建议使用 OBD 进行标准部署；具体操作参见 通过 OBD 白屏部署OceanBase 集群。

对于 kubernetes 环境，建议使用 ob-operator 的方式部署；具体操作参见 在 Kubernetes 集群中部署 OceanBase 数据库。

## 4、OCP

OceanBase 云平台（OceanBase Cloud Platform，简称 OCP）伴随 OceanBase 数据库而生，是一款以 OceanBase 数据库为核心的企业级数据库管理平台。

通过 OCP，您可以一键安装、升级、扩容、卸载 OceanBase 数据库集群，创建和管理运维任务，监控集群的运行状态，并查看告警。

OCP 当前支持 OceanBase 数据库的所有主流版本，不仅提供对 OceanBase 集群和租户等组件的全生命周期管理服务，同时也对 OceanBase 数据库相关的资源（主机、网络和软件包等）

提供管理服务，让您能够更加高效地管理 OceanBase 集群，降低企业的 IT 运维成本。

对于 OCP 的部署，目前支持单节点、三节点(高可用)和多 AZ 部署模式。

OCP 产品以 Docker 形态运行，对服务器结构和 Linux 操作系统的要求与 OceanBase 数据库服务器一致。

单节点部署

通过单个节点提供全部 OCP 能力。单节点部署的负载均衡模式为 none。

三节点部署

OCP 支持通过三节点部署来实现高可用。

三节点部署可以选择 DNS 负载均衡或者其他外部负载均衡设备，例如 F5 等。

多 AZ 部署

可用区（Available-Zone，Azone）指由承载 OceanBase 业务的一个或多个机房映射出的逻辑区域。

OCP 的多 AZ（Multi Available-Zone，多可用区）模式是指将同一个 OCP 集群分别部署到多个可用区中，并优先以可用区为边界，来限定 OCP、OceanBase 和 OBProxy 之间的访问服务链路。各可用区内承载的业务会优先由其本区域内的 OCP 管理。

## 5、部署

### 中控机器

存储 OceanBase 数据库安装包和集群配置信息的机器。

### 目标机器

安装 OceanBase 数据库的机器。

### OBD

OceanBase Deployer，OceanBase 开源软件的安装部署工具，简称为 OBD。

### OBProxy

OceanBase Database Proxy，OceanBase 高性能反向代理服务器，简称为 OBProxy。

### OCP

OceanBase Cloud Platform，OceanBase 运维管理工具，简称为 OCP。

注：社区版本可以用

