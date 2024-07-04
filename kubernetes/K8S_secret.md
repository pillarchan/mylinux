```
secret资源的增删改查实战:
[root@k8s231.oldboyedu.com secret]# kubectl get secrets  es-https 
NAME       TYPE     DATA   AGE
es-https   Opaque   2      44s
[root@k8s231.oldboyedu.com secret]# 
[root@k8s231.oldboyedu.com secret]# 
[root@k8s231.oldboyedu.com secret]# kubectl apply -f 01-secret-demo.yaml 
secret/es-https configured
[root@k8s231.oldboyedu.com secret]# 
[root@k8s231.oldboyedu.com secret]# kubectl get secrets  es-https 
NAME       TYPE     DATA   AGE
es-https   Opaque   3      49s
[root@k8s231.oldboyedu.com secret]# 
[root@k8s231.oldboyedu.com secret]# 
[root@k8s231.oldboyedu.com secret]# cat 01-secret-demo.yaml 
apiVersion: v1
kind: Secret
metadata:
  name: es-https
data:
  username: ZWxhc3RpYwo=
  password: b2xkYm95ZWR1Cg==
  hostip: MTAuMC4wLjI1MAo=
[root@k8s231.oldboyedu.com secret]# 
[root@k8s231.oldboyedu.com secret]# kubectl delete -f 01-secret-demo.yaml 
secret "es-https" deleted
[root@k8s231.oldboyedu.com secret]# 



Pod基于env引用secret资源案例:
[root@k8s231.oldboyedu.com secret]# cat 02-secret-env.yaml 
apiVersion: v1
kind: Pod
metadata:
  name: linux85-game-secret-001
spec:
  nodeName: k8s232.oldboyedu.com
  containers:
  - name: game
    image: harbor.oldboyedu.com/oldboyedu-games/jasonyin2020/oldboyedu-games:v0.7
    env:
    - name: OLDBOYEDU_LINUX85_USERNAME
      valueFrom:
        # 指定引用的secret资源
        secretKeyRef:
          # 指定secret的名称
          name: es-https
          # 指定secret的KEY
          key: username
    - name: OLDBOYEDU_LINUX85_PASSWORD
      valueFrom:
        secretKeyRef:
          name: es-https
          key: password
    - name: OLDBOYEDU_LINUX85_HOSTIP
      valueFrom:
        secretKeyRef:
          name: es-https
          key: hostip
[root@k8s231.oldboyedu.com secret]# 
[root@k8s231.oldboyedu.com secret]# kubectl apply -f 02-secret-env.yaml 
pod/linux85-game-secret-001 created
[root@k8s231.oldboyedu.com secret]# 
[root@k8s231.oldboyedu.com secret]# kubectl get pods
NAME                                 READY   STATUS                       RESTARTS         AGE
linux85-game-secret-001              1/1     Running                      0                2s
[root@k8s231.oldboyedu.com secret]# 
[root@k8s231.oldboyedu.com secret]# 
[root@k8s231.oldboyedu.com secret]# kubectl exec linux85-game-secret-001 -- env


Pod基于存储卷引用secret资源案例
[root@k8s231.oldboyedu.com secret]# cat 03-secret-volumes.yaml 
apiVersion: v1
kind: Pod
metadata:
  name: linux85-volume-secret-003
spec:
  nodeName: k8s232.oldboyedu.com
  volumes:
  - name: data
    # 指定存储卷的类型为secret
    secret:
      # 指定secret的名称
      secretName: es-https
      items:
      - key: username
        path: username.info
      - key: password
        path: password.info
      - key: hostip
        path: hostip.info
  containers:
  - name: web
    image: harbor.oldboyedu.com/web/nginx:1.20.1-alpine
    command: ["tail","-f","/etc/hosts"]
    volumeMounts:
    - name: data
      # mountPath: /oldboyedu-data
      mountPath: /etc/nginx/nginx.conf
      subPath: username.info
    - name: data
      mountPath: /etc/nginx/password.conf
      subPath: password.info
    - name: data
      mountPath: /etc/nginx/hostip.conf
      subPath: hostip.info
[root@k8s231.oldboyedu.com secret]# 
[root@k8s231.oldboyedu.com secret]# kubectl apply -f 03-secret-volumes.yaml 
pod/linux85-volume-secret-003 configured
[root@k8s231.oldboyedu.com secret]#
```

# secret资源