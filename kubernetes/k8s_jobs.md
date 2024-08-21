# Job概述

​	一次性任务，Pod完成作业后并不重启容器。其重启策略为"restartPolicy: Never"

```
apiVersion: batch/v1
kind: Job
metadata: 
  name: jobs-demo-1
spec:
  template:
    metadata:
      labels: 
        app: job-yoyo
    spec:
      containers:
      - name: jobs-demo
        image: busybox
        imagePullPolicy: IfNotPresent
        command: ["sh","-c","for i in $(seq 1 10);do echo $i;done"] 
      restartPolicy: Never
  backoffLimit: 3
```

CronJob概述:
	周期性任务，CronJob底层逻辑是周期性创建Job控制器来实现周期性任务的。

```
  # 定义调度格式，参考链接：https://en.wikipedia.org/wiki/Cron
  # ┌───────────── 分钟 (0 - 59)
  # │ ┌───────────── 小时 (0 - 23)
  # │ │ ┌───────────── 月的某天 (1 - 31)
  # │ │ │ ┌───────────── 月份 (1 - 12)
  # │ │ │ │ ┌───────────── 周的某天 (0 - 6)（周日到周一；在某些系统上，7 也是星期日）
  # │ │ │ │ │                          或者是 sun，mon，tue，web，thu，fri，sat
  # │ │ │ │ │
  # │ │ │ │ │
  # * * * * *
```

```
apiVersion: batch/v1
kind: CronJob
metadata: 
  name: jobs-cronjob-demo-1
spec:
  schedule: "*/1 * * * *"
  jobTemplate:
    spec:
      template:
        metadata:
          labels: 
            app: job-yoyo
        spec:
          containers:
          - name: jobs-cronjob-demo
            image: busybox
            imagePullPolicy: IfNotPresent
            command: ["sh","-c","date;echo 'i would like to drink wahaha'"] 
          restartPolicy: OnFailure
#      backoffLimit: 3
```

