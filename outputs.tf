#
# Outputs
#

locals {
  aws_auth = <<CONFIGMAPAWSAUTH

apiVersion: v1
kind: ConfigMap
metadata:
  name: aws-auth
  namespace: kube-system
data:
  mapRoles: |
    - rolearn: ${aws_iam_role.vb-node.arn}
      username: system:node:{{EC2PrivateDNSName}}
      groups:
        - system:bootstrappers
        - system:nodes
CONFIGMAPAWSAUTH

  kubeconfig = <<KUBECONFIG

apiVersion: v1
clusters:
- cluster:
    server: ${aws_eks_cluster.vb.endpoint}
    certificate-authority-data: ${aws_eks_cluster.vb.certificate_authority.0.data}
  name: ${aws_eks_cluster.vb.name}
contexts:
- context:
    cluster: ${aws_eks_cluster.vb.name}
    user: ${aws_eks_cluster.vb.name}
  name: ${aws_eks_cluster.vb.name}
current-context: ${aws_eks_cluster.vb.name}
kind: Config
preferences:
  calico: ${var.enable-calico}
  dashboard: ${var.enable-dashboard}
users:
- name: ${aws_eks_cluster.vb.name}
  user:
    exec:
      apiVersion: client.authentication.k8s.io/v1alpha1
      command: aws-iam-authenticator
      args:
        - "token"
        - "-i"
        - "${aws_eks_cluster.vb.name}"
KUBECONFIG
}

output "aws_auth" {
  description = "A kubernetes ConfigMap that applies role mappings to allow nodes to register with the cluster"
  value = local.aws_auth
}

output "kubeconfig" {
  description = "A generated kubeconfig for accessing the cluster"
  value = local.kubeconfig
}
