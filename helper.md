aws eks update-kubeconfig --region eu-central-1 --name k8s-autoscaling --role-arn arn:aws:iam::069987675187:role/tf-terraform-user
kubectl set env daemonset aws-node -n kube-system ENABLE_PREFIX_DELEGATION=true WARM_IP_TARGET=2 MINIMUM_IP_TARGET=12
