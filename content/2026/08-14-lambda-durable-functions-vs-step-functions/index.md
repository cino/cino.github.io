+++
author = "Ricardo Cino"
title = "Lambda Durable Functions vs Step Functions: Choosing the Right Workflow Orchestrator in 2026"
slug = "lambda-durable-functions-vs-step-functions"
date = 2026-08-14T12:00:00+01:00
tags = [
  "aws",
  "serverless",
  "lambda",
  "durable functions",
  "step functions",
  "workflows",
  "orchestration",
  "comparison",
  "architecture",
]
images = []
+++

When AWS introduced Lambda Durable Functions in 2026, it honestly caught my attention more than I expected. I've never been a huge fan of Step Functions - don't get me wrong, it works and it's reliable, but I always found the Amazon States Language JSON definitions clunky to work with. And the testing? That was the real pain point. You either had to mock the entire Step Functions environment with all its quirks, or actually deploy to AWS just to verify your workflow logic. Neither option was great, and it made iteration slow.

But Lambda Durable Functions changes this completely. Now I can write my workflow in actual TypeScript code, use my existing testing frameworks like Jest, mock the durable context directly in unit tests, and get immediate feedback in my local development environment. No more waiting for deployments. No more complex mocking of state machines. For someone who spends a lot of time writing tests and values fast feedback loops, this is genuinely exciting.

So when I see teams struggling with the choice between Step Functions and Durable Functions, I get it. The new approach isn't just a different way to orchestrate workflows - it's a fundamentally different development experience. That said, both have their place depending on your specific requirements and constraints. The choice comes down to more than just technical features or personal preference.

<!--more-->

## Why This Choice Matters

Building stateful workflows in serverless has always been Step Functions territory. It works, it's reliable, and we all know how to use it. But then Lambda Durable Functions came along with a different promise: write your workflow in actual code, not JSON definitions.

For some teams this is exactly what they've been waiting for. For others, it just adds confusion. I've seen both reactions firsthand, and honestly, they both make sense depending on what you're trying to build.

## What Are Lambda Durable Functions?

Lambda Durable Functions let you build stateful, long-running workflows directly within Lambda. Instead of defining your workflow in Amazon States Language, you write it in TypeScript, Python, or whatever language you're already using for Lambda.

### Key Features

- **State persistence**: Your workflow state is automatically maintained between executions
- **Checkpointing**: Pause and resume workflows from the last checkpoint
- **Built-in retries**: Automatic retry logic for transient failures
- **Long-running**: Workflows can span hours or days, not just minutes
- **Seamless Lambda integration**: Works with your existing functions and triggers

### Example: Simple Durable Function

```typescript
import { durable } from "@aws-lambda-durable/functions";

export const handler = durable(async (context) => {
  const orderId = await processOrder(context.input);

  const paymentResult = await context.retry(() => chargePayment(orderId), {
    maxAttempts: 3,
    delay: 1000,
  });

  await sendConfirmationEmail(orderId, paymentResult);
  return { orderId, paymentResult };
});
```

### Pricing

Durable Functions use the standard Lambda pricing with these additions:

- **$8 per million durable operations**
- **$0.25 per GB of state written**
- **$0.15 per GB-month of state retained**

## What Is AWS Step Functions?

Step Functions has been around since 2016 and is the established way to coordinate AWS services into serverless workflows. You define your workflow as a state machine in JSON (Amazon States Language), and it handles the orchestration.

### Key Features

- **Visual workflow definition**: JSON-based state machines
- **Service integration**: Native integrations with 200+ AWS services
- **Advanced error handling**: Configurable retry policies and catch blocks
- **Long-running workflows**: Can run for up to **1 year**
- **Audit trail**: Complete execution history and logging

### Example: Step Function State Machine

```json
{
  "StartAt": "ProcessOrder",
  "States": {
    "ProcessOrder": {
      "Type": "Task",
      "Resource": "arn:aws:lambda:us-east-1:123456789012:function:process-order",
      "Next": "ChargePayment"
    },
    "ChargePayment": {
      "Type": "Task",
      "Resource": "arn:aws:lambda:us-east-1:123456789012:function:charge-payment",
      "Next": "SendConfirmation"
    },
    "SendConfirmation": {
      "Type": "Task",
      "Resource": "arn:aws:lambda:us-east-1:123456789012:function:send-confirmation",
      "End": true
    }
  }
}
```

### Pricing

Step Functions pricing is based on:

- **$0.025 per 1,000 state transitions**
- **$0.25 per GB-month of state storage**

## Head-to-Head Comparison

### Development Experience

| Aspect               | Lambda Durable Functions  | Step Functions                   |
| -------------------- | ------------------------- | -------------------------------- |
| **Learning Curve**   | Low (Lambda SDK)          | Medium (ASL, new concepts)       |
| **Code Style**       | Imperative (code)         | Declarative (JSON)               |
| **Language Support** | All Lambda runtimes       | Amazon States Language           |
| **Local Testing**    | Easy (standard Lambda)    | Requires AWS or local emulator   |
| **Debugging**        | Standard Lambda debugging | Console-based, execution history |

### Workflow Capabilities

| Feature                  | Lambda Durable Functions                                        | Step Functions                    |
| ------------------------ | --------------------------------------------------------------- | --------------------------------- |
| **Max Duration**         | Lambda timeout (15 min standard, 90 min with Managed Instances) | 1 year                            |
| **State Storage**        | Automatic, managed                                              | Automatic, managed                |
| **Error Handling**       | Built-in retries                                                | Advanced (retry, catch, fallback) |
| **Parallel Execution**   | Built-in via SDK (`context.parallel`)                           | Built-in (Parallel state)         |
| **Conditional Logic**    | Code-based (if/else)                                            | Built-in (Choice state)           |
| **Wait/Delay**           | Built-in                                                        | Built-in (Wait state)             |
| **Service Integrations** | Lambda (can call other services through Lambda code)            | 200+ AWS services                 |
| **Human Approval**       | No                                                              | Yes (via Lambda)                  |

### Pricing Comparison

For a workflow with 10 steps, 100,000 executions/month, 1MB state, 5 min average execution:

| Service                  | Cost Estimate                               |
| ------------------------ | ------------------------------------------- |
| Lambda Durable Functions | ~$8 (ops) + ~$0.25 (state) + Lambda compute |
| Step Functions           | ~$25 (transitions) + ~$0.25 (storage)       |

## When to Use Lambda Durable Functions

In my experience, Durable Functions work best when:

- Your workflow is primarily Lambda-based
- You prefer writing imperative code over declarative JSON
- Your workflow completes within 15-90 minutes
- You want to minimize operational complexity
- You're already comfortable with Lambda

**Good for:** Order processing, data transformation, API orchestration, scheduled tasks, form processing.

## When to Use Step Functions

Step Functions still has the edge when:

- Your workflow runs for hours, days, or longer
- You need to orchestrate multiple AWS services beyond Lambda
- You need advanced patterns like parallel branches, conditional routing, or human approval
- You need a complete audit trail of every state transition
- You need maximum reliability for business-critical workflows

**Good for:** ETL pipelines, approval workflows, IoT processing, microservices orchestration, IT automation.

## The Hybrid Approach

Here's something I've seen work well: use Step Functions for the overall orchestration, but drop into Lambda Durable Functions for complex, stateful processing steps. This gives you the best of both worlds - Step Functions' orchestration power with Durable Functions' code-based workflows for the heavy lifting.

```
API Gateway → Step Functions
    ↓
[Step 1: Validate]
    ↓
[Lambda Durable Function: Complex Processing]
    ↓
[Step 2: Store Results]
    ↓
DynamoDB
```

## Decision Framework

When I'm helping teams decide, I ask these questions:

1. **How long will it run?** Under 15 minutes → Durable Functions. Over 15 minutes → Step Functions.

2. **What services are involved?** Lambda only → Durable Functions. Multiple AWS services → Step Functions.

3. **How complex is the logic?** Simple/linear → Durable Functions. Complex with branches/parallel → Step Functions.

4. **Do you need human approval?** Yes → Step Functions. No → Either works.

5. **What's your team's expertise?** Lambda experts → Durable Functions. Step Functions experience → Step Functions.

## Real-World Example: Order Processing

Let me show you how the same order processing workflow looks in both approaches.

### Durable Functions Approach

```typescript
import { durable } from "@aws-lambda-durable/functions";

export const handler = durable(async (context) => {
  const validation = await validateOrder(context.input);
  if (!validation.valid) throw new Error("Invalid order");

  const inventory = await context.retry(() => checkInventory(validation.items), {
    maxAttempts: 3,
  });

  const payment = await processPayment(context.input.paymentMethod, inventory.total);
  await updateInventory(inventory.items);
  await sendConfirmationEmail(context.input.customerEmail, payment);

  return { orderId: context.input.orderId, status: "completed" };
});
```

**When to choose this:** All steps are Lambda functions, workflow completes quickly, you want code-based development.

### Step Functions Approach

```json
{
  "StartAt": "ValidateOrder",
  "States": {
    "ValidateOrder": {
      "Type": "Task",
      "Resource": "arn:aws:lambda:...:function:validate-order",
      "Next": "CheckInventory"
    },
    "CheckInventory": {
      "Type": "Task",
      "Resource": "arn:aws:lambda:...:function:check-inventory",
      "Next": "PaymentChoice"
    },
    "PaymentChoice": {
      "Type": "Choice",
      "Choices": [
        {
          "Variable": "$.paymentMethod",
          "StringEquals": "credit_card",
          "Next": "ProcessCreditCard"
        },
        {
          "Variable": "$.paymentMethod",
          "StringEquals": "paypal",
          "Next": "ProcessPayPal"
        }
      ],
      "Default": "InvalidPayment"
    },
    "ProcessCreditCard": {
      "Type": "Task",
      "Resource": "arn:aws:lambda:...:function:process-credit-card",
      "Next": "UpdateInventory"
    },
    "ProcessPayPal": {
      "Type": "Task",
      "Resource": "arn:aws:lambda:...:function:process-paypal",
      "Next": "UpdateInventory"
    },
    "UpdateInventory": {
      "Type": "Task",
      "Resource": "arn:aws:lambda:...:function:update-inventory",
      "Next": "SendConfirmation"
    },
    "SendConfirmation": {
      "Type": "Task",
      "Resource": "arn:aws:lambda:...:function:send-confirmation",
      "End": true
    }
  }
}
```

**When to choose this:** You need conditional logic based on payment method, or other complex routing.

## My Take

Both services have their place. Lambda Durable Functions gives you the simplicity of writing workflows in code, which is great for teams that live in their IDE. But Step Functions offers capabilities that are hard to match - especially for long-running, complex workflows that need to coordinate across multiple services.

If I'm building something quick and Lambda-centric, I'll reach for Durable Functions. If I'm building something that needs to be robust, long-running, and coordinate across AWS services, Step Functions is still my go-to. And increasingly, I'm seeing the hybrid approach work well for complex systems.

The good news is that AWS now gives you real options. The choice depends on what you're building and how you like to work.

{{< article-footer >}}
