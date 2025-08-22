CORS FOR AWS APIGATWAY

Step 1: Preflight (OPTIONS)

Before the real POST, the browser sends an OPTIONS request.

(a) Method Request

Browser calls OPTIONS /order.

API Gateway matches it to your OPTIONS method.

No authorization / parameters (unless you added them).

(b) Integration Request

Since it’s a MOCK integration, API Gateway doesn’t call a backend.

Instead, it uses your request template:

{ "statusCode": 200 }

(c) Integration Response

Takes the MOCK result and maps it to status code 200.

Adds CORS headers you defined in response_parameters:

Access-Control-Allow-Origin

Access-Control-Allow-Methods

Access-Control-Allow-Headers

(d) Method Response

Returns a 200 response with the above headers exposed.

👉 Browser sees the headers → CORS preflight succeeds.