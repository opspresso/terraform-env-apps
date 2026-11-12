# 8-runway-target-two

Agent Runway `stg` 환경의 `eb` target `two-eb-amd64`가 쓰는 계정 nalbam-two(`552292899126`, `ap-northeast-2`)의 리소스입니다.
앱 host는 `<slug>.two.rovr.dev`, `<slug>-<env>.two.rovr.dev`입니다. Agent Runway는 계정 opspresso(`396608815058`)의 `eks-demo`에서 실행됩니다.
계약은 agent-platform `docs/APP_DELIVERY.md`의 "외부 계정", 배포 workflow는 argocd-env-projects `charts/delivery/files/app-deploy-eb.yaml`·`app-remove-eb.yaml`·`eb-stack.yaml`입니다.

| 리소스 | 용도 |
| --- | --- |
| VPC `agent-runway`(`10.20.0.0/16`) | public subnet 2개(load balancer), private subnet 2개(instance), NAT gateway 1개, S3 gateway endpoint. instance는 public 주소가 없다(`eb-stack.yaml` `AssociatePublicIpAddress: false`) |
| Route53 zone `two.rovr.dev` | 앱 host 레코드. deploy role은 `*.two.rovr.dev` 레코드만 바꾼다 |
| NS 레코드 `two.rovr.dev`(opspresso `rovr.dev` zone) | 위 zone의 위임. provider `aws.management`(기본 자격 증명)로 만든다 |
| ACM 인증서 `*.two.rovr.dev` | load balancer HTTPS listener. 위 zone의 DNS 레코드로 검증한다 |
| KMS `alias/agent-runway` | SecureString Variable 암호화(`secretsKeyArn`). `prevent_destroy`로 보호한다 |
| module `target`(`modules/runway-target`) | app boundary, deploy role `agent-runway-target-deploy`, EB 서비스 역할, bucket `agent-runway-two-eb-amd64-552292899126`, secrets 역할 `agent-runway-target-secrets` |

두 역할은 opspresso의 역할(`demo/7-eks-shared`)만 신뢰하고, 둘 다 Agent Runway가 만든 external ID(`sts:ExternalId`)를 요구한다.

| 역할 | 넘겨받는 주체 | 하는 일 |
| --- | --- | --- |
| `agent-runway-target-deploy` | `pod-role--delivery-target`(`app-deploy-eb`·`app-remove-eb` 스텝) | session tag의 Project 환경 stack `runway-<project>-<env>`만 만들고 바꾼다 |
| `agent-runway-target-secrets` | `pod-role--agent-runway`(Agent Runway) | `/agent-runway/two-eb-amd64/*` Variable을 이 계정의 KMS key로 쓰고 읽고 지운다 |

앱 이미지는 opspresso ECR `projects/<slug>`에 있다. `demo/8-app-delivery`의 registry policy가 이 계정의 instance 역할 `runway-*-app`의 pull을 허용한다.

출력 `account`와 `eb_target`은 관리자가 Agent Runway 환경 `stg`에 입력할 값이다(비밀 값 없음). `egress_ip`는 instance가 외부로 나가는 주소다.

## 준비

- AWS CLI profile `nalbam-two`(AWS SSO)와 opspresso 기본 자격 증명이 모두 필요하다. state는 opspresso bucket에 있고 기본 자격 증명으로 읽는다.
  각 provider는 `allowed_account_ids`로 계정을 확인하므로 자격 증명이 바뀌면 plan이 멈춘다. 다른 profile 이름은 `-var profile=<이름>`으로 준다.
- `runway_external_id`가 필요하다. 값은 Agent Runway 콘솔 **관리 > 환경 > stg**의 External ID다. 공개 저장소이므로 Git에 넣지 않고
  `TF_VAR_runway_external_id` 환경변수나 미추적 `terraform.tfvars`로 준다. 값이 없으면 plan이 시작하지 않는다.

## 적용 순서

1. `demo/7-eks-shared`(`pod-role--delivery-target`, `pod-role--agent-runway`)가 적용되어 있어야 한다. trust policy가 두 역할을 가리킨다.
2. Agent Runway 관리자가 환경 `stg`에 `account`(`id`, `region`, `access.secretsRole`)를 저장한다. Agent Runway가 `access.externalId`를 만든다.
   machine target이 아직 없으므로 접근 확인은 하지 않는다.
3. 이 디렉터리를 적용한다. 인증서 검증은 NS 위임이 퍼진 뒤 끝나므로 몇 분 걸릴 수 있다.

   ```bash
   export TF_VAR_runway_external_id=<External ID>
   terraform init
   terraform plan
   terraform apply
   terraform output -json eb_target
   ```

4. `demo/8-app-delivery`를 적용한다(registry policy). 3과 순서는 상관없지만 첫 배포 전에 끝나야 한다.
5. 관리자가 `stg`에 출력 `eb_target`을 target으로 추가한다. 저장할 때 Agent Runway가 접근을 확인하고 `verifiedAt`을 기록한다.
   실패하면 `accessError`를 확인하고 고친 뒤 `POST /api/environments/stg/access-check`를 요청한다.

## 비용과 위험

- 고정 비용은 월 약 48 USD다(ap-northeast-2, 730시간 기준): NAT gateway 약 43 USD(시간당 0.059 USD)와 처리량 GB당 0.059 USD,
  NAT의 public IPv4 약 3.65 USD, hosted zone 0.50 USD, KMS key 1 USD. VPC·subnet·S3 gateway endpoint는 비용이 없다.
  S3로 가는 traffic(source bundle, ECR image layer)은 gateway endpoint를 지나므로 NAT 처리 요금이 붙지 않는다.
- EB 환경마다 ALB(시간당 약 0.0225 USD와 LCU), ALB public IPv4 2개, instance 비용이 따로 든다.
- NAT gateway가 하나라서 그 AZ(`a`)에 장애가 나면 다른 AZ instance도 외부로 나가지 못한다. 실행 중인 앱의 응답은 계속되지만 배포와
  Variable 읽기, image pull은 실패한다. AZ마다 NAT를 두면 NAT 비용이 AZ 수만큼 늘어난다.
- NAT instance는 더 싸지만(월 약 7 USD) OS 관리와 단일 instance 장애를 떠안으므로 쓰지 않는다. interface endpoint(ECR·SSM·Logs·
  Elastic Beanstalk·CloudFormation 등)는 AZ 2개 기준 NAT보다 비싸다.
- `AdministratorAccess-AWSElasticBeanstalk`와 그 위의 Deny(`runway-isolation`)는 `8-runway-target`과 같다. 이 계정에서는 Agent Runway가 아닌
  EB 애플리케이션을 운영하지 않는다.
