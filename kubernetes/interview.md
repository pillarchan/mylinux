# k8s面试题

## 1.如何知道其它的运维人员对K8S进行了哪些操作？

结合K8S架构和POD的启动流程去思考

## 2.管理K8s集群的方式

		命令行的方式 kubectl --kubeconfig=xxx.kubeconfig
		- 图形化管理:
			- 单套机群:
				- Dashboard:
					- token
					- kubeconfig
					
			- K8S自动化运维平台: （互联网公司，医疗，）
				- 运维架构师,云计算讲师,
				- 运维开发: ... 25K-35K
				- 容器运维: ... 15K-25K
				- 应用运维: ... 10K-15K
				------
				- IDC运维
				- 网络运维
				
			- 开源的管理方式:
				- rancher
				- kubesphere