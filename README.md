
# Architecture Diagram Generator

An automated tool to generate architecture diagrams from code files using AWS services, Python, Terraform, and PlantUML. This project significantly reduces code analysis time by translating code into pseudocode, generating UML code, and producing diagrams.

---

## Table of Contents

- [Overview](#overview)
- [Features](#features)
- [Architecture](#architecture)
- [Technologies Used](#technologies-used)
- [Getting Started](#getting-started)
  - [Prerequisites](#prerequisites)
  - [Installation](#installation)
- [Project Structure](#project-structure)
- [Usage](#usage)
- [Contributing](#contributing)
- [License](#license)
- [Acknowledgements](#acknowledgements)

---

## Overview

The **Architecture Diagram Generator** is designed to automate the creation of architecture diagrams from code files. It streamlines the process by:

1. Translating uploaded code files into pseudocode using the Claude AI model.
2. Generating UML code from the pseudocode.
3. Creating UML diagrams using PlantUML.
4. Uploading the generated files to an AWS S3 bucket.
5. Allowing users to download the pseudocode, UML code, and diagrams through a front-end interface.

---

## Features

- **Automated Pseudocode Generation**: Converts code into structured pseudocode focusing on important function calls and database interactions.
- **UML Code Generation**: Transforms pseudocode into UML code suitable for diagram creation.
- **Diagram Creation**: Utilizes PlantUML to generate visual diagrams in SVG format.
- **AWS Integration**: Leverages AWS Lambda, Step Functions, API Gateway, and S3 for scalable and efficient processing.
- **User-Friendly Interface**: Provides a front-end application for users to upload code and download generated outputs.
- **Infrastructure as Code**: Employs Terraform for automated provisioning of AWS resources.
- **Extensible Design**: Modular architecture allows for easy maintenance and scalability.

---

## Architecture

The system architecture comprises the following components:

1. **Front-End Application**: A web interface where users can upload code files and download outputs.
2. **API Gateway**: Serves as the entry point to trigger the processing workflow.
3. **AWS Step Functions**: Orchestrates the sequence of Lambda functions.
4. **Lambda Functions**:
   - **Translate to Pseudocode**: Converts code files into pseudocode.
   - **Generate UML Code**: Creates UML code from pseudocode.
   - **Generate Diagram**: Produces UML diagrams using PlantUML.
5. **AWS S3 Bucket**: Stores the pseudocode, UML code, and diagrams.
6. **IAM Roles and Policies**: Manages permissions for AWS services.

**Workflow Diagram**:

```plaintext
[User] --uploads code--> [Front-End] --triggers--> [API Gateway] --> [Step Functions]
[Step Functions]:
   1. [Lambda: Translate to Pseudocode] --uploads to--> [S3]
   2. [Lambda: Generate UML Code] --uploads to--> [S3]
   3. [Lambda: Generate Diagram] --uploads to--> [S3] --returns URLs--> [Front-End]
[User] --downloads outputs from--> [Front-End]
```

---

## Technologies Used

- **Programming Language**: Python
- **Cloud Provider**: AWS
  - AWS Lambda
  - AWS Step Functions
  - AWS API Gateway
  - AWS S3
- **Infrastructure as Code**: Terraform
- **Diagram Tool**: PlantUML
- **AI Model**: Claude AI API
- **Front-End**: HTML, CSS, JavaScript

---

## Getting Started

### Prerequisites

- **AWS Account**: With permissions to create Lambda functions, S3 buckets, API Gateways, and Step Functions.
- **Terraform**: Installed on your local machine.
- **Claude API Access**: Obtain an API key from the Claude AI platform.
- **Python**: Version 3.8 or higher.
- **Node.js and npm**: For front-end dependencies (optional).

### Installation

1. **Clone the Repository**:

   ```bash
   git clone https://github.com/Cara-jr/architecture-diagram-generator.git
   cd architecture-diagram-generator
   ```

2. **Set Up AWS Credentials**: Configure your AWS CLI with the necessary credentials.

3. **Configure Terraform Variables**: Update the `variables.tf` file in the `terraform` directory with your configurations.

4. **Deploy AWS Infrastructure**:

   ```bash
   cd terraform
   terraform init
   terraform apply
   ```

5. **Set Up Front-End**:

   - Navigate to the `frontend` directory.
   - Update the `script.js` file with your API Gateway endpoint.
   - Serve the front-end files using a static server or open `index.html` directly.

---

## Project Structure

```plaintext
architecture-diagram-generator/
├── lambda_functions/
│   ├── translate_to_pseudocode/
│   │   ├── lambda_function.py
│   │   ├── requirements.txt
│   │   └── unit_tests.py
│   ├── generate_uml_code/
│   │   ├── lambda_function.py
│   │   ├── requirements.txt
│   │   └── unit_tests.py
│   ├── generate_diagram/
│   │   ├── lambda_function.py
│   │   ├── requirements.txt
│   │   └── unit_tests.py
│   └── layers/
│       └── plantuml/
│           ├── plantuml.jar
│           └── (other dependencies)
├── frontend/
│   ├── index.html
│   ├── styles.css
│   └── script.js
├── config/
│   ├── dev_config.py
│   └── prod_config.py
├── terraform/
│   ├── provider.tf
│   ├── variables.tf
│   ├── iam.tf
│   ├── lambda.tf
│   ├── api_gateway.tf
│   ├── step_functions.tf
│   ├── s3.tf
│   └── outputs.tf
├── README.md
└── LICENSE
```

---

## Usage

1. **Access the Front-End Application**: Open the `index.html` file in your web browser.

2. **Upload a Code File**: Use the upload button to select a code file (e.g., `.py`, `.java`, `.js`, `.cs`).

3. **Generate Diagram**: Click on the "Generate Diagram" button to start the processing workflow.

4. **Download Outputs**:

   - **Pseudocode**: The translated pseudocode file.
   - **UML Code**: The generated UML code file.
   - **Diagram**: The UML diagram in SVG format.

---

## Contributing

Contributions are welcome! Please follow these steps:

1. **Fork the Repository**: Create your own fork of the project.

2. **Create a Feature Branch**:

   ```bash
   git checkout -b feature/YourFeature
   ```

3. **Commit Your Changes**:

   ```bash
   git commit -am 'Add new feature'
   ```

4. **Push to the Branch**:

   ```bash
   git push origin feature/YourFeature
   ```

5. **Open a Pull Request**: Submit your pull request for review.

---

## License

This project is licensed under the [MIT License](LICENSE).

---

## Acknowledgements

- **AWS**: For providing scalable cloud services.
- **Terraform**: For enabling infrastructure as code.
- **PlantUML**: For diagram generation capabilities.
- **Claude AI**: For advanced language processing.

---

**Note**: Replace placeholders like `yourusername`, `your-unique-s3-bucket-name`, and API endpoints with your actual configurations. Ensure all AWS resources are properly secured and follow best practices for IAM roles and policies.

---
