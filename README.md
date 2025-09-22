<!-- Improved compatibility of back to top link -->
<a id="readme-top"></a>

<!-- PROJECT SHIELDS -->
[![Contributors][contributors-shield]][contributors-url]
[![Forks][forks-shield]][forks-url]
[![Stargazers][stars-shield]][stars-url]
[![Issues][issues-shield]][issues-url]
[![project_license][license-shield]][license-url]
[![LinkedIn][linkedin-shield]][linkedin-url]

<!-- PROJECT LOGO -->
<br />
<div align="center">
  <a href="https://github.com/ThomasGates3/Fraud-Detection-Pipeline">
    <img src="images/logo.png" alt="Logo" width="80" height="80">
  </a>

<h3 align="center">Fraud Detection Pipeline (Terraform + AWS)</h3>

  <p align="center">
    End-to-end machine learning fraud detection system deployed with AWS & Terraform.
    <br />
    <a href="https://github.com/ThomasGates3/Fraud-Detection-Pipeline"><strong>Explore the docs »</strong></a>
    <br />
    <br />
    <a href="https://github.com/ThomasGates3/Fraud-Detection-Pipeline">View Demo</a>
    ·
    <a href="https://github.com/ThomasGates3/Fraud-Detection-Pipeline/issues/new?labels=bug&template=bug-report---.md">Report Bug</a>
    ·
    <a href="https://github.com/ThomasGates3/Fraud-Detection-Pipeline/issues/new?labels=enhancement&template=feature-request---.md">Request Feature</a>
  </p>
</div>

---

<!-- TABLE OF CONTENTS -->
<details>
  <summary>Table of Contents</summary>
  <ol>
    <li><a href="#about-the-project">About The Project</a></li>
    <li><a href="#built-with">Built With</a></li>
    <li><a href="#getting-started">Getting Started</a></li>
    <li><a href="#usage">Usage</a></li>
    <li><a href="#roadmap">Roadmap</a></li>
    <li><a href="#contributing">Contributing</a></li>
    <li><a href="#license">License</a></li>
    <li><a href="#contact">Contact</a></li>
    <li><a href="#acknowledgments">Acknowledgments</a></li>
  </ol>
</details>

---

## About The Project

[![Fraud Detection Architecture][product-screenshot]](images/fraud_architecture.png)

This project demonstrates an **end-to-end fraud detection system** built on AWS using Terraform.

- **API Gateway** accepts transactions via a REST API.
- **Lambda (Inference)** validates and sends requests to a **SageMaker Endpoint** hosting the ML fraud model.
- **SQS** queues transactions for batch/async processing.
- **Lambda (SQS Handler)** consumes queued events for further actions.
- **CloudWatch** monitors logs and metrics.
- **S3** serves as a data lake for storing transaction records.

<p align="right">(<a href="#readme-top">back to top</a>)</p>

---

### Built With

* [![Terraform][Terraform]][Terraform-url]
* [![AWS Lambda][Lambda]][Lambda-url]
* [![Amazon S3][S3]][S3-url]
* [![Amazon SageMaker][SageMaker]][SageMaker-url]
* [![Amazon API Gateway][APIGW]][APIGW-url]
* [![Amazon SQS][SQS]][SQS-url]
* [![Amazon CloudWatch][CloudWatch]][CloudWatch-url]

<p align="right">(<a href="#readme-top">back to top</a>)</p>

---

## Getting Started

### Prerequisites
- AWS Account with IAM setup  
- Terraform CLI installed  
- AWS CLI configured (`aws configure`)  

### Installation
```sh
git clone https://github.com/ThomasGates3/Fraud-Detection-Pipeline.git
cd Fraud-Detection-Pipeline
terraform init
terraform apply -auto-approve
```

<p align="right">(<a href="#readme-top">back to top</a>)</p>

---

## Usage

Submit a transaction to the Fraud Detection API:

```bash
curl -X POST https://<api-id>.execute-api.<region>.amazonaws.com/prod/infer   -H "Content-Type: application/json"   -d '{"transaction_id": "12345", "amount": 250.0, "user_id": "abc"}'
```

Response:
```json
{
  "transaction_id": "12345",
  "prediction": "fraudulent",
  "confidence": 0.92
}
```

<p align="right">(<a href="#readme-top">back to top</a>)</p>

---

## Roadmap

- [ ] Add SageMaker training job Terraform module  
- [ ] CI/CD integration with GitHub Actions  
- [ ] Add real fraud dataset preprocessing pipeline  
- [ ] Visualization dashboard with QuickSight  

<p align="right">(<a href="#readme-top">back to top</a>)</p>

---

## Contributing

1. Fork the repo  
2. Create your Feature Branch (`git checkout -b feature/new-feature`)  
3. Commit your Changes (`git commit -m 'Add new feature'`)  
4. Push to the Branch (`git push origin feature/new-feature`)  
5. Open a Pull Request  

<p align="right">(<a href="#readme-top">back to top</a>)</p>

---

## License

Distributed under the MIT License. See `LICENSE` for details.

<p align="right">(<a href="#readme-top">back to top</a>)</p>

---

## Contact

Your Name – [@twitter_handle](https://twitter.com/twitter_handle) – email@example.com  

Project Link: [https://github.com/ThomasGates3/Fraud-Detection-Pipeline](https://github.com/ThomasGates3/Fraud-Detection-Pipeline)

<p align="right">(<a href="#readme-top">back to top</a>)</p>

---

## Acknowledgments

* AWS Documentation  
* Terraform Registry  
* OpenAI for guidance  

<p align="right">(<a href="#readme-top">back to top</a>)</p>

---

<!-- MARKDOWN LINKS -->
[contributors-shield]: https://img.shields.io/github/contributors/ThomasGates3/Fraud-Detection-Pipeline.svg?style=for-the-badge
[contributors-url]: https://github.com/ThomasGates3/Fraud-Detection-Pipeline/graphs/contributors
[forks-shield]: https://img.shields.io/github/forks/ThomasGates3/Fraud-Detection-Pipeline.svg?style=for-the-badge
[forks-url]: https://github.com/ThomasGates3/Fraud-Detection-Pipeline/network/members
[stars-shield]: https://img.shields.io/github/stars/ThomasGates3/Fraud-Detection-Pipeline.svg?style=for-the-badge
[stars-url]: https://github.com/ThomasGates3/Fraud-Detection-Pipeline/stargazers
[issues-shield]: https://img.shields.io/github/issues/ThomasGates3/Fraud-Detection-Pipeline.svg?style=for-the-badge
[issues-url]: https://github.com/ThomasGates3/Fraud-Detection-Pipeline/issues
[license-shield]: https://img.shields.io/github/license/ThomasGates3/Fraud-Detection-Pipeline.svg?style=for-the-badge
[license-url]: https://github.com/ThomasGates3/Fraud-Detection-Pipeline/blob/master/LICENSE
[linkedin-shield]: https://img.shields.io/badge/-LinkedIn-black.svg?style=for-the-badge&logo=linkedin&colorB=555
[linkedin-url]: https://linkedin.com/in/thomas-gates-iii

[product-screenshot]: images/fraud_architecture.png
[Terraform]: https://img.shields.io/badge/Terraform-844FBA?style=for-the-badge&logo=terraform&logoColor=white
[Terraform-url]: https://www.terraform.io/
[Lambda]: https://img.shields.io/badge/AWS%20Lambda-FF9900?style=for-the-badge&logo=awslambda&logoColor=white
[Lambda-url]: https://aws.amazon.com/lambda/
[S3]: https://img.shields.io/badge/Amazon%20S3-569A31?style=for-the-badge&logo=amazons3&logoColor=white
[S3-url]: https://aws.amazon.com/s3/
[SageMaker]: https://img.shields.io/badge/Amazon%20SageMaker-1D4E89?style=for-the-badge&logo=amazonaws&logoColor=white
[SageMaker-url]: https://aws.amazon.com/sagemaker/
[APIGW]: https://img.shields.io/badge/API%20Gateway-FF4F00?style=for-the-badge&logo=amazonapigateway&logoColor=white
[APIGW-url]: https://aws.amazon.com/api-gateway/
[SQS]: https://img.shields.io/badge/Amazon%20SQS-4A154B?style=for-the-badge&logo=amazonsqs&logoColor=white
[SQS-url]: https://aws.amazon.com/sqs/
[CloudWatch]: https://img.shields.io/badge/Amazon%20CloudWatch-652D90?style=for-the-badge&logo=amazoncloudwatch&logoColor=white
[CloudWatch-url]: https://aws.amazon.com/cloudwatch/
