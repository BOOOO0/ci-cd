# CI/CD

클라우드 인프라를 코드로 구축하고 배포 자동화 파이프라인을 구축합니다.

## terraform

terraform을 사용해서 앱을 배포하기 위해 필요한 리소스들을 구축합니다.

```
📦terraform
 ┣ 📜terraform.tfstate
 ┣ 📜networks_ec2.tf
 ┣ 📜provider.tf
 ┗ 📜s3.tf
```

셸에서 `aws configure`을 통해 자격 증명을 한 후 `provider.tf`에 사용할 리전을 명시하고 `terraform init` 명령어로 AWS API를 다운로드 받습니다.       

EC2 인스턴스를 사용하기 위해 네트워크 리소스를 먼저 구성합니다.

VPC, subnet, IGW, Routing table을 정의하며 리소스가 생성될 때 할당되는 VPC의 id를 VPC 내부에 생성될 리소스에 명시합니다.

그리고 보안 그룹 리소스를 생성하여 인바운드, 아웃바운드 규칙을 정합니다.

Jenkins 서버의 포트가 8080이므로 http 프로토콜 포트, SSH 프로토콜 포트 외에 8080 포트에 대한 인바운드 규칙을 추가합니다.

젠킨스 서버와 Nginx 웹 서버 사이의 통신을 위해 젠킨스 서버의 SSH 퍼블릭 키를 웹 서버에 전달하고 젠킨스가 빌드해서 생성한 Artifact를 배포를 위해 웹 서버에 전달하기 위해서 S3 버켓을 생성합니다.     

## Jenkins

Github Webhook에 Jenkins 서버의 URL을 등록합니다.     

Jenkins는 main 브랜치에 소스 코드가 push되면 미리 작성된 Jenkins 파일에서 명시된 작업(의존성 설치, 빌드, 배포를 위한 ansible 스크립트 실행)을 수행합니다.     

## Ansible

Ansible 스크립트로 하나의 EC2 인스턴스에는 Jenkins를 다른 하나의 EC2 인스턴스에는 Nginx 웹 서버를 설치합니다.       

그리고 두 인스턴스의 통신을 위해 Jenkins 서버의 SSH 퍼블릭 키를 S3 버킷에 업로드하고 Nginx 서버는 퍼블릭 키를 다운로드 하도록 합니다.       

Jenkins에서 빌드를 수행한 후 생성된 Artifact를 S3 버킷에 업로드하고 자신의 워크 디렉토리에서 미리 작성한 배포를 위한 Ansible 스크립트를 실행합니다.

배포를 위한 Ansible 스크립트에는 Nginx 서버가 설치된 인스턴스에 자신의 root 디렉토리의 파일을 삭제하고 S3에서 다운로드 받은 Artifact를 root 디렉토리에서 배포되도록 합니다.
