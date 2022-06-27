k apply -f app2.yaml
k apply -f app1.yaml
k apply -f hpa.yaml


viddy kubectl resource-capacity -u -p -n app2
hey --disable-keepalive -z 30m -c 50 -n 10 http://app2.damien-jacinto.com/


vpa
hey --disable-keepalive -z 30m -c 5 -n 1 http://localhost:9000

kubectl resource-capacity -u -p

aws eks update-kubeconfig --region eu-central-1 --name k8s-autoscaling --role-arn arn:aws:iam::069987675187:role/tf-terraform-user
kubectl set env daemonset aws-node -n kube-system ENABLE_PREFIX_DELEGATION=true WARM_IP_TARGET=2 MINIMUM_IP_TARGET=12


ec2-instance-selector --memory-max 16 --memory-min 2 --vcpus-min 2 --vcpus-max 6 --cpu-architecture x86_64 -r eu-central-1 -o list --max-results 100 --gpus 0 --inference-accelerators 0 --network-interfaces-min 3 --hypervisor nitro --hibernation-support 1
