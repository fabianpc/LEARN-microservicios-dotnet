#!/bin/bash

# Variables

AWS_REGION="us-east-1"

SQS_QUEUE_NAME="pickage"

SNS_TOPIC_ADULTS="adultstopic"

SNS_TOPIC_CHILDREN="childrentopic"

SQS_ADULTS_QUEUE="adultsQueue"

SQS_CHILDREN_QUEUE="childrenQueue"

CLUSTER_NAME="microservices-cluster"

# Configurar región por defecto (opcional)

aws configure set region $AWS_REGION

echo "✅ Creando cola SQS principal: $SQS_QUEUE_NAME"

aws sqs create-queue --queue-name $SQS_QUEUE_NAME

echo "✅ Creando tópicos SNS"

ADULTS_TOPIC_ARN=$(aws sns create-topic --name $SNS_TOPIC_ADULTS --query "TopicArn" --output text)

CHILDREN_TOPIC_ARN=$(aws sns create-topic --name $SNS_TOPIC_CHILDREN --query "TopicArn" --output text)

echo "✅ Creando colas SQS para suscripciones"

ADULTS_QUEUE_URL=$(aws sqs create-queue --queue-name $SQS_ADULTS_QUEUE --query "QueueUrl" --output text)

CHILDREN_QUEUE_URL=$(aws sqs create-queue --queue-name $SQS_CHILDREN_QUEUE --query "QueueUrl" --output text)

# Obtener ARN de las colas

ADULTS_QUEUE_ARN=$(aws sqs get-queue-attributes --queue-url $ADULTS_QUEUE_URL --attribute-names QueueArn --query "Attributes.QueueArn" --output text)

CHILDREN_QUEUE_ARN=$(aws sqs get-queue-attributes --queue-url $CHILDREN_QUEUE_URL --attribute-names QueueArn --query "Attributes.QueueArn" --output text)

echo "✅ Configurando políticas de acceso para que SNS pueda publicar en SQS"

POLICY=$(cat <<EOF

{

  "Version": "2012-10-17",

  "Statement": [{

    "Effect": "Allow",

    "Principal": "*",

    "Action": "SQS:SendMessage",

    "Resource": "$ADULTS_QUEUE_ARN",

    "Condition": {

      "ArnEquals": {

        "aws:SourceArn": "$ADULTS_TOPIC_ARN"

      }

    }

  }]

}

EOF

)

aws sqs set-queue-attributes 

 --queue-url $ADULTS_QUEUE_URL

  --attributes Policy="$POLICY"

POLICY2=$(cat <<EOF

{

  "Version": "2012-10-17",

  "Statement": [{

    "Effect": "Allow",

    "Principal": "*",

    "Action": "SQS:SendMessage",

    "Resource": "$CHILDREN_QUEUE_ARN",

    "Condition": {

      "ArnEquals": {

        "aws:SourceArn": "$CHILDREN_TOPIC_ARN"

      }

    }

  }]

}

EOF

)

aws sqs set-queue-attributes 

 --queue-url $CHILDREN_QUEUE_URL

  --attributes Policy="$POLICY2"

echo "✅ Suscribiendo colas SQS a los tópicos SNS"

aws sns subscribe --topic-arn $ADULTS_TOPIC_ARN --protocol sqs --notification-endpoint $ADULTS_QUEUE_ARN

aws sns subscribe --topic-arn $CHILDREN_TOPIC_ARN --protocol sqs --notification-endpoint $CHILDREN_QUEUE_ARN

echo "✅ Creando cluster ECS para microservicios"

aws ecs create-cluster --cluster-name $CLUSTER_NAME

echo "🎉 Infraestructura lista: SQS, SNS y ECS configurados"