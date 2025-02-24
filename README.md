# MyRead

A Web Application for ride-sharing service where you can book a ride around your area using AWS services available on free tier. 
This project is refered from the original [Amazon workshop](https://aws.amazon.com/serverless-workshops). 

## ⚙️ Source Code

FrontEnd and others: [aws-web-app](https://github.com/RoshanRajcmd/aws-web-app)

## 📚 Architecture

* Angular
* AWS
  * Lambda
  * DynamoDB
  * Amplify
  * API Gateway
  * Cognito
  * IAM

<img width="1306" alt="Screenshot 2025-02-23 at 7 12 06 PM" src="https://github.com/user-attachments/assets/81419f94-470e-4026-aff5-12c601a3011b" />


## 🎛️ Features

1. Incorporated into a CI/CD pipeline with Amplify.
2. Account creation and log in. 
3. Map is powered by ArcGIS. 

## Cost
All services used are eligible for the [AWS Free Tier](https://aws.amazon.com/free/).  Outside of the Free Tier, there may be small charges associated with building the app (less than $1 USD), but charges will continue to incur if you leave the app running.  Please see the end of the YouTube video for instructions on how to delete all resources used in the video.

## 📸 Screenshots

## 🧑‍💻 Developer setup

*AWS* 

Build a general VPC structure with Public and Private subnets, Route table and Internet gateway for you setup based on the above architecture diagram.

*Amplify Setup*

Go to AWS Amplify and Click Create new APP.
Choose the code base repository and brach from your GitHub Account.
If needed add in your build compand and build location. And click Deploy to deploy the application.
Note: Amplify have a automated pipeline for CI/CD by default when a app is created and that will detect and deploy any new changes pushed into the selected branch.


### The Lambda Function Code
Here is the code for the Lambda function, originally taken from the [AWS workshop](https://aws.amazon.com/getting-started/hands-on/build-serverless-web-app-lambda-apigateway-s3-dynamodb-cognito/module-3/ ), and updated for Node 20.x:

```node
import { randomBytes } from 'crypto';
import { DynamoDBClient } from '@aws-sdk/client-dynamodb';
import { DynamoDBDocumentClient, PutCommand } from '@aws-sdk/lib-dynamodb';

const client = new DynamoDBClient({});
const ddb = DynamoDBDocumentClient.from(client);

const fleet = [
    { Name: 'Angel', Color: 'White', Gender: 'Female' },
    { Name: 'Gil', Color: 'White', Gender: 'Male' },
    { Name: 'Rocinante', Color: 'Yellow', Gender: 'Female' },
];

export const handler = async (event, context) => {
    if (!event.requestContext.authorizer) {
        return errorResponse('Authorization not configured', context.awsRequestId);
    }

    const rideId = toUrlString(randomBytes(16));
    console.log('Received event (', rideId, '): ', event);

    const username = event.requestContext.authorizer.claims['cognito:username'];
    const requestBody = JSON.parse(event.body);
    const pickupLocation = requestBody.PickupLocation;

    const unicorn = findUnicorn(pickupLocation);

    try {
        await recordRide(rideId, username, unicorn);
        return {
            statusCode: 201,
            body: JSON.stringify({
                RideId: rideId,
                Unicorn: unicorn,
                Eta: '30 seconds',
                Rider: username,
            }),
            headers: {
                'Access-Control-Allow-Origin': '*',
            },
        };
    } catch (err) {
        console.error(err);
        return errorResponse(err.message, context.awsRequestId);
    }
};

function findUnicorn(pickupLocation) {
    console.log('Finding unicorn for ', pickupLocation.Latitude, ', ', pickupLocation.Longitude);
    return fleet[Math.floor(Math.random() * fleet.length)];
}

async function recordRide(rideId, username, unicorn) {
    const params = {
        TableName: 'Rides',
        Item: {
            RideId: rideId,
            User: username,
            Unicorn: unicorn,
            RequestTime: new Date().toISOString(),
        },
    };
    await ddb.send(new PutCommand(params));
}

function toUrlString(buffer) {
    return buffer.toString('base64')
        .replace(/\+/g, '-')
        .replace(/\//g, '_')
        .replace(/=/g, '');
}

function errorResponse(errorMessage, awsRequestId) {
    return {
        statusCode: 500,
        body: JSON.stringify({
            Error: errorMessage,
            Reference: awsRequestId,
        }),
        headers: {
            'Access-Control-Allow-Origin': '*',
        },
    };
}
```

### The Lambda Function Test Function
Here is the code used to test the Lambda function:

```json
{
    "path": "/ride",
    "httpMethod": "POST",
    "headers": {
        "Accept": "*/*",
        "Authorization": "eyJraWQiOiJLTzRVMWZs",
        "content-type": "application/json; charset=UTF-8"
    },
    "queryStringParameters": null,
    "pathParameters": null,
    "requestContext": {
        "authorizer": {
            "claims": {
                "cognito:username": "the_username"
            }
        }
    },
    "body": "{\"PickupLocation\":{\"Latitude\":47.6174755835663,\"Longitude\":-122.28837066650185}}"
}
```

