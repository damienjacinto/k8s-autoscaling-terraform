k apply -f app2.yaml
k apply -f app1.yaml
k apply -f hpa.yaml


viddy kubectl resource-capacity -u -p -n app2
hey --disable-keepalive -z 30m -c 50 -n 10 http://app2.damien-jacinto.com/




aws eks update-kubeconfig --region eu-central-1 --name k8s-autoscaling --role-arn arn:aws:iam::069987675187:role/tf-terraform-user
kubectl set env daemonset aws-node -n kube-system ENABLE_PREFIX_DELEGATION=true WARM_IP_TARGET=2 MINIMUM_IP_TARGET=12
