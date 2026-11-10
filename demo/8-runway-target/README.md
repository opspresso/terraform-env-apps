# 8-runway-target

Agent Runway `aws-eb` Target `demo-eb`의 계정 리소스입니다. 설계는 agent-platform `docs/DELIVERY_V3.md`(D1·D2), 배포 workflow는
argocd-env-projects `charts/delivery/files/app-deploy-eb.yaml`·`app-remove-eb.yaml`·`eb-stack.yaml`입니다.

| 리소스 | 용도 |
| --- | --- |
| IAM role `agent-runway-target-deploy` | VM Target workflow 단계(ServiceAccount `delivery-target`, 역할 `pod-role--delivery-target`)가 session tag `delivery-project`·`delivery-env`로 넘겨받는다. 그 session은 stack `runway-<project>-<environment>`, 이름이 `runway-<project>-<environment>-*`이고 app boundary가 있는 role·instance profile, 그 환경의 source bundle, `*.apps.rovr.dev` 레코드만 바꾼다. EB 환경의 Auto Scaling group·load balancer는 EB가 호출자 권한으로 만들므로 `AdministratorAccess-AWSElasticBeanstalk`를 붙인다 |
| IAM policy `agent-runway-app-boundary` | stack이 만드는 instance role의 상한. EB web tier, `/agent-runway/demo-eb/*` Variable, `projects/*` 이미지 읽기만 허용한다 |
| IAM role `agent-runway-eb-service` | EB 서비스 역할(enhanced health, managed update) |
| S3 bucket `agent-runway-demo-eb-<account>` | source bundle `<project>/<environment>/<Deployment ID>.zip`. 비밀 값은 없다. 90일 뒤 만료된다 |

출력 `target`은 Agent Runway에 Target으로 등록할 값이다(비밀 값 없음).

## 적용 순서

1. terraform-env-demo `demo/4-role`(역할 `pod-role--delivery-target`)과 `demo/5-eks`(Pod Identity `app-delivery/delivery-target`)를 적용한다.
   deploy role의 trust policy가 그 역할을 가리키므로 역할이 먼저 있어야 한다.
2. 이 디렉터리를 적용한다.

## 비용과 위험

- 이 디렉터리의 리소스 자체는 비용이 거의 없다(S3 bundle 저장만). EB 환경마다 ALB와 instance 비용이 든다.
- `AdministratorAccess-AWSElasticBeanstalk`는 계정의 모든 EB 애플리케이션을 바꿀 수 있다. 이 계정에서 다른 EB 애플리케이션을 운영하면
  deploy role을 그 애플리케이션에 쓸 수 있으므로 Target 전용 계정을 쓴다.
