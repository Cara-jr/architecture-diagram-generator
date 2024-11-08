# Architecture Diagram Generator

An automated tool to generate architecture diagrams from code files using AWS services, Python, Terraform, and PlantUML. This project significantly reduces code analysis time by translating code into pseudocode, generating UML code, and producing diagrams.

---

## Table of Contents

- [Overview](#overview)
- [Features](#features)
- [Architecture](#architecture)
- [Technologies Used](#technologies-used)
- [Getting Started](#getting-started)
- [Project Structure](#project-structure)
- [Usage](#usage)
- [Contributing](#contributing)
- [License](#license)

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
