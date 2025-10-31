exports.handler = async (event, context) => {
    console.log("Received event:", JSON.stringify(event, null, 2));
    
    let message = 'Hello from Lambda!';


    if (event.httpMethod) {
        message = `API Gateway triggered me with method: ${event.httpMethod} and path: ${event.path}`;
    } 
    else if (event.Records && event.Records[0].eventSource === 'aws:s3') {
        message = `S3 triggered me with event: ${event.Records[0].eventName} on bucket: ${event.Records[0].s3.bucket.name}`;
    }
    else if (event["detail-type"] === "Scheduled Event") {
        message = `Scheduler triggered me at ${new Date().toISOString()}`;
    }

    return {
        statusCode: 200,
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ message: message }),
    };
};