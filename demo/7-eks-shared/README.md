# 7-eks-shared

여러 opspresso 서비스가 함께 쓰는 `eks-demo`(terraform-env-demo `demo/5-eks`)의 전용 리소스를 둔다.

| 파일 | 내용 |
| --- | --- |
| `20-pod-roles.tf`, `policies/` | Pod Identity 역할 `pod-role--<key>`와 정책. 키 목록은 `03-locals.tf`의 `pod_identities` |
| `30-pod-identity.tf` | 위 역할과 ServiceAccount를 잇는 `eks-demo` association |
| `40-github-roles.tf` | opspresso 저장소 CI가 assume하는 GitHub Actions 역할 |
| `60-`~`65-*.tf` | 전용 NodeClass·NodePool |

역할 이름은 다른 root와 서비스가 이름으로 참조한다(예: `pod-role--agent-runway`, `pod-role--delivery-target`). 이름을 바꾸지 않는다.
이 root는 AWS와 Kubernetes provider를 함께 쓰므로 plan에도 `eks-demo` API 접근 권한이 필요하다.

## Node pool

opspresso 서비스 전용 NodeClass·NodePool을 둔다.
기본 노드(`baseline-*`, `general`)와 GitHub Actions runner pool은 terraform-env-demo `demo/6-eks-node`가 관리한다.
EKS 관리형 default NodeClass·NodePool은 변경하지 않는다.

| NodePool | 사용처 |
| --- | --- |
| `workspaces` | Agent Forge Sandbox Job(Workspace) |
| `rovr-sandboxes` | rovr sub-agent run |
| `delivery-amd64` | Agent Runway Release의 `linux/amd64` build |

Workspace pool은 기존 Auto Mode node 역할과 private subnet·EKS primary security group을 재사용한다.
`workspaces` NodeClass는 암호화된 160Gi ephemeral disk, `DefaultDeny`와 network policy event log를 사용한다.
전용 taint와 `karpenter.sh/nodepool=workspaces`로 앱·DB와 실행 Pod를 분리하고, pool의 총 한도는
`workspace_max_pods=32`에서는 CPU 48개·메모리 384Gi다. 4-CPU 노드당 1-CPU/2Gi 실행 Pod
3개와 kubelet·DaemonSet 여유를 계산하고 교체용 노드 1개를 허용한다. 노드는 수요가 있을 때만
생성한다. namespace quota와 worker 동시성은 `argocd-env-apps`가 소유하며 같은 용량으로 맞춘다.
노드의 이미지 캐시는 kubelet이 관리하며 Workspace마다 DinD 이미지 사본을 저장하지 않는다.
`argocd-env-addons`의 EKS network policy controller를 먼저 준비한다.

rovr sandbox pool(`rovr-sandboxes`)은 `workspaces` NodeClass를 재사용하고 taint `rovr.dev/sandbox`로
rovr 실행 Pod만 받는다. 실행 Pod는 2 CPU·4Gi를 요청하므로 8-CPU m·r 노드(32Gi 이상)에 3개씩 배치한다.
한도는 `rovr_sandbox_max_pods=6`에서 노드 3대(CPU 24개·메모리 192Gi)이며 교체용 노드 1대를 포함한다.
이 값은 `argocd-env-apps`의 `env/eks-demo.yaml` `rovr.sandbox.max_runs`와 같게 유지한다.
실행 Pod는 `karpenter.sh/do-not-disrupt`를 달고, 노드 drain은 rovr sandbox 마감(90분)까지 기다린다. Spot 회수는 2분 예고 뒤 실행 중인 run을 중단시킨다.

`delivery-amd64` pool은 Agent Runway Release의 amd64 image를 native로 build한다(argocd-env-projects `charts/delivery`
`files/app-build-v2.yaml`). 다른 NodePool은 모두 arm64다. taint `opspresso.com/delivery-build`로 `app-build-v2`의 `build` step만 받고,
build가 없으면 비어 있다. Spot만 쓰므로 Spot 회수는 실행 중인 Release build를 실패시킨다.

공유 Agent PostgreSQL과 다른 중요 서비스는 terraform-env-demo `demo/6-eks-node`의 on-demand `core-2a`·`core-2c` NodePool에서 실행한다.
