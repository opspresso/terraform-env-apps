# One-time adoption of the NodeClass and NodePools that terraform-env-demo demo/6-eks-node created.
# Remove this file after the import is applied.
import {
  to = kubernetes_manifest.workspace_node_class
  id = "apiVersion=eks.amazonaws.com/v1,kind=NodeClass,name=workspaces"
}

import {
  to = kubernetes_manifest.workspace_node_pool
  id = "apiVersion=karpenter.sh/v1,kind=NodePool,name=workspaces"
}

import {
  to = kubernetes_manifest.rovr_sandbox_node_pool
  id = "apiVersion=karpenter.sh/v1,kind=NodePool,name=rovr-sandboxes"
}

import {
  to = kubernetes_manifest.delivery_amd64_node_pool
  id = "apiVersion=karpenter.sh/v1,kind=NodePool,name=delivery-amd64"
}
