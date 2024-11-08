resource "aws_sfn_state_machine" "diagram_generator" {
  name     = "DiagramGeneratorStateMachine"
  role_arn = aws_iam_role.step_functions_role.arn
  definition = jsonencode({
    Comment: "State machine to orchestrate Lambda functions",
    StartAt: "TranslateToPseudocode",
    States: {
      TranslateToPseudocode: {
        Type: "Task",
        Resource: aws_lambda_function.translate_to_pseudocode.arn,
        Next: "GenerateUMLCode",
        Retry: [
          {
            ErrorEquals: ["Lambda.ServiceException", "Lambda.AWSLambdaException", "Lambda.SdkClientException"],
            IntervalSeconds: 2,
            MaxAttempts: 6,
            BackoffRate: 2.0
          }
        ],
        Catch: [
          {
            ErrorEquals: ["States.ALL"],
            ResultPath: "$.error",
            Next: "Failure"
          }
        ]
      },
      GenerateUMLCode: {
        Type: "Task",
        Resource: aws_lambda_function.generate_uml_code.arn,
        Next: "GenerateDiagram",
        Retry: [
          {
            ErrorEquals: ["Lambda.ServiceException", "Lambda.AWSLambdaException", "Lambda.SdkClientException"],
            IntervalSeconds: 2,
            MaxAttempts: 6,
            BackoffRate: 2.0
          }
        ],
        Catch: [
          {
            ErrorEquals: ["States.ALL"],
            ResultPath: "$.error",
            Next: "Failure"
          }
        ]
      },
      GenerateDiagram: {
        Type: "Task",
        Resource: aws_lambda_function.generate_diagram.arn,
        End: true,
        Retry: [
          {
            ErrorEquals: ["Lambda.ServiceException", "Lambda.AWSLambdaException", "Lambda.SdkClientException"],
            IntervalSeconds: 2,
            MaxAttempts: 6,
            BackoffRate: 2.0
          }
        ],
        Catch: [
          {
            ErrorEquals: ["States.ALL"],
            ResultPath: "$.error",
            Next: "Failure"
          }
        ]
      },
      Failure: {
        Type: "Fail",
        Error: "StateMachineError",
        Cause: "An error occurred in the state machine"
      }
    }
  })
}
