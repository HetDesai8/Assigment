import json
import logging
import os

logger = logging.getLogger()
logger.setLevel(logging.INFO)

def handler(event, context):
    """
    The main handler for the Lambda function.
    Processes events from various AWS sources (API Gateway, S3, SQS, Scheduler).
    """
    logger.info(f"Received event: {json.dumps(event, indent=2)}")
    
    stage = os.environ.get('STAGE', 'default')

    try:

        if 'Records' in event and event['Records'][0].get('eventSource') == 'aws:sqs':
            for record in event['Records']:
                message_body = json.loads(record['body'])
                logger.info(f"Processing SQS message from stage {stage}. Body: {message_body}")
            return {
                'statusCode': 200,
                'body': f'Successfully processed {len(event["Records"])} SQS messages.'
            }

        elif 'Records' in event and event['Records'][0].get('eventSource') == 'aws:s3':
            for record in event['Records']:
                bucket_name = record['s3']['bucket']['name']
                object_key = record['s3']['object']['key']
                logger.info(f"New object in S3. Bucket: {bucket_name}, Key: {object_key}")
            return {'status': 'S3 event processed'}

        elif event.get('source') == 'aws.events' and event.get('detail-type') == 'Scheduled Event':
            logger.info(f"Scheduler event triggered processing in {stage} at {context.get_remaining_time_in_millis()}ms remaining.")
            return {'status': 'Scheduled event processed'}

        else:
            logger.warning("Event source unknown or API Gateway direct invoke.")
            return {
                'statusCode': 200,
                'body': json.dumps({'message': f'Processor Lambda running in {stage}. Event type: API Gateway or unknown.'})
            }

    except Exception as e:
        logger.error(f"Error processing event: {e}")
        return {
            'statusCode': 500,
            'body': json.dumps({'error': str(e)})
        }
