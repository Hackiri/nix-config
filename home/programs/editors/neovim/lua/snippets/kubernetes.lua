local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node
local f = ls.function_node
local fmt = require("luasnip.extras.fmt").fmt

local kubernetes_snippets = {
  -- Deployment
  s(
    "k8sdeploy",
    fmt(
      [[
apiVersion: apps/v1
kind: Deployment
metadata:
  name: {}
  namespace: {}
  labels:
    app: {}
spec:
  replicas: {}
  selector:
    matchLabels:
      app: {}
  template:
    metadata:
      labels:
        app: {}
    spec:
      containers:
      - name: {}
        image: {}:{}
        ports:
        - containerPort: {}
        env:
        - name: {}
          value: "{}"
        resources:
          requests:
            memory: "{}Mi"
            cpu: "{}m"
          limits:
            memory: "{}Mi"
            cpu: "{}m"]],
      {
        i(1, "app-deployment"),
        i(2, "default"),
        i(3, "myapp"),
        i(4, "3"),
        f(function(args)
          return args[1][1]
        end, { 3 }),
        f(function(args)
          return args[1][1]
        end, { 3 }),
        f(function(args)
          return args[1][1]
        end, { 3 }),
        i(5, "myapp"),
        i(6, "latest"),
        i(7, "8080"),
        i(8, "ENV_VAR"),
        i(9, "value"),
        i(10, "128"),
        i(11, "100"),
        i(12, "256"),
        i(13, "200"),
      }
    )
  ),

  -- Service
  s(
    "k8ssvc",
    fmt(
      [[
apiVersion: v1
kind: Service
metadata:
  name: {}
  namespace: {}
  labels:
    app: {}
spec:
  type: {}
  selector:
    app: {}
  ports:
  - port: {}
    targetPort: {}
    protocol: TCP
    name: {}]],
      {
        i(1, "app-service"),
        i(2, "default"),
        i(3, "myapp"),
        i(4, "ClusterIP"),
        f(function(args)
          return args[1][1]
        end, { 3 }),
        i(5, "80"),
        i(6, "8080"),
        i(7, "http"),
      }
    )
  ),

  -- ConfigMap
  s(
    "k8scm",
    fmt(
      [[
apiVersion: v1
kind: ConfigMap
metadata:
  name: {}
  namespace: {}
data:
  {}: {}
  {}: |
    {}]],
      {
        i(1, "app-config"),
        i(2, "default"),
        i(3, "key"),
        i(4, "value"),
        i(5, "config.yaml"),
        i(6, "# YAML content"),
      }
    )
  ),

  -- Secret
  s(
    "k8ssecret",
    fmt(
      [[
apiVersion: v1
kind: Secret
metadata:
  name: {}
  namespace: {}
type: {}
data:
  {}: {}]],
      {
        i(1, "app-secret"),
        i(2, "default"),
        i(3, "Opaque"),
        i(4, "key"),
        i(5, "base64encodedvalue"),
      }
    )
  ),

  -- Ingress
  s(
    "k8sing",
    fmt(
      [[
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: {}
  namespace: {}
  annotations:
    {}: "{}"
spec:
  ingressClassName: {}
  rules:
  - host: {}
    http:
      paths:
      - path: {}
        pathType: {}
        backend:
          service:
            name: {}
            port:
              number: {}]],
      {
        i(1, "app-ingress"),
        i(2, "default"),
        i(3, "cert-manager.io/cluster-issuer"),
        i(4, "letsencrypt-prod"),
        i(5, "nginx"),
        i(6, "app.example.com"),
        i(7, "/"),
        i(8, "Prefix"),
        i(9, "app-service"),
        i(10, "80"),
      }
    )
  ),

  -- StatefulSet
  s(
    "k8ssts",
    fmt(
      [[
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: {}
  namespace: {}
spec:
  serviceName: {}
  replicas: {}
  selector:
    matchLabels:
      app: {}
  template:
    metadata:
      labels:
        app: {}
    spec:
      containers:
      - name: {}
        image: {}:{}
        ports:
        - containerPort: {}
        volumeMounts:
        - name: {}
          mountPath: {}
  volumeClaimTemplates:
  - metadata:
      name: {}
    spec:
      accessModes: [ "ReadWriteOnce" ]
      resources:
        requests:
          storage: {}Gi]],
      {
        i(1, "app-statefulset"),
        i(2, "default"),
        i(3, "app"),
        i(4, "3"),
        i(5, "myapp"),
        f(function(args)
          return args[1][1]
        end, { 5 }),
        f(function(args)
          return args[1][1]
        end, { 5 }),
        i(6, "myapp"),
        i(7, "latest"),
        i(8, "8080"),
        i(9, "data"),
        i(10, "/data"),
        f(function(args)
          return args[1][1]
        end, { 9 }),
        i(11, "10"),
      }
    )
  ),

  -- PersistentVolumeClaim
  s(
    "k8spvc",
    fmt(
      [[
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: {}
  namespace: {}
spec:
  accessModes:
  - {}
  resources:
    requests:
      storage: {}Gi
  storageClassName: {}]],
      {
        i(1, "app-pvc"),
        i(2, "default"),
        i(3, "ReadWriteOnce"),
        i(4, "10"),
        i(5, "standard"),
      }
    )
  ),

  -- Job
  s(
    "k8sjob",
    fmt(
      [[
apiVersion: batch/v1
kind: Job
metadata:
  name: {}
  namespace: {}
spec:
  backoffLimit: {}
  template:
    spec:
      containers:
      - name: {}
        image: {}:{}
        command: [{}]
        args: [{}]
      restartPolicy: {}]],
      {
        i(1, "job-name"),
        i(2, "default"),
        i(3, "3"),
        i(4, "job"),
        i(5, "busybox"),
        i(6, "latest"),
        i(7, '"/bin/sh"'),
        i(8, '"-c", "echo hello"'),
        i(9, "Never"),
      }
    )
  ),

  -- CronJob
  s(
    "k8scron",
    fmt(
      [[
apiVersion: batch/v1
kind: CronJob
metadata:
  name: {}
  namespace: {}
spec:
  schedule: "{}"
  jobTemplate:
    spec:
      template:
        spec:
          containers:
          - name: {}
            image: {}:{}
            command: [{}]
          restartPolicy: OnFailure]],
      {
        i(1, "cronjob-name"),
        i(2, "default"),
        i(3, "0 * * * *"),
        i(4, "job"),
        i(5, "busybox"),
        i(6, "latest"),
        i(7, '"/bin/sh", "-c", "echo hello"'),
      }
    )
  ),

  -- Namespace
  s(
    "k8sns",
    fmt(
      [[
apiVersion: v1
kind: Namespace
metadata:
  name: {}
  labels:
    {}: {}]],
      {
        i(1, "namespace-name"),
        i(2, "environment"),
        i(3, "production"),
      }
    )
  ),

  -- HorizontalPodAutoscaler
  s(
    "k8shpa",
    fmt(
      [[
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: {}
  namespace: {}
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: {}
  minReplicas: {}
  maxReplicas: {}
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: {}]],
      {
        i(1, "app-hpa"),
        i(2, "default"),
        i(3, "app-deployment"),
        i(4, "2"),
        i(5, "10"),
        i(6, "80"),
      }
    )
  ),

  -- ServiceAccount
  s(
    "k8ssa",
    fmt(
      [[
apiVersion: v1
kind: ServiceAccount
metadata:
  name: {}
  namespace: {}]],
      {
        i(1, "app-sa"),
        i(2, "default"),
      }
    )
  ),
}

return kubernetes_snippets
