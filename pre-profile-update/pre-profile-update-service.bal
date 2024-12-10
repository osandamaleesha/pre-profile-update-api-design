import ballerina/http;
import ballerina/openapi;

@http:ServiceConfig {basePath: "/extension.com"}
type OASServiceType service object {
    *http:ServiceContract;

    @openapi:ResourceInfo {
        examples: {
            "requestBody": {
                "application/json": {
                    "Default": {
                        "filePath": "Examples/Request/Request.json"
                    }
                }
            },
            "response": {
                "200": {
                    "examples": {
                        "application/json": {
                            "SUCCESS Status for pre update profile action": {
                                "filePath": "Examples/Response/SUCCESS Status for pre update profile action.json"
                            },
                            "SUCCESS Status for pre update profile action with operations": {
                                "filePath": "Examples/Response/SUCCESS Status for pre update profile action with operations.json"
                            },
                            "FAILED Status" : {
                                "filePath": "Examples/Response/FAILED Status.json"
                            },
                            "FAILED Status for pre update profile action with context" : {
                                "filePath": "Examples/Response/FAILED Status for pre update profile action with context.json"
                            },
                            "INCOMPLETE Status with redirection" : {
                                "filePath": "Examples/Response/INCOMPLETE Status with redirection.json"
                            }
                        }
                    }
                },
                "400": {
                    "examples": {
                        "application/json": {
                            "BadRequest" : {
                                "value": {
                                    "actionStatus": "ERROR",
                                    "failureReason": "invalid_input",
                                    "failureDescription": "User attributes are invalidated."
                                }
                            }
                        }
                    }
                },
                "500": {
                    "examples": {
                        "application/json": {
                            "ServerError" : {
                                "value": {
                                    "actionStatus": "ERROR",
                                    "error": "server_error",
                                    "errorDescription": "Profile update request is invalid." 
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    resource function post .(@http:Payload RequestBody payload) returns SuccessResponse|ErrorResponseBadRequest|ErrorResponseInternalServerError;
};

# Represents a successful HTTP response.
public type SuccessResponse record {|
    *http:Ok;
    SuccessResponseType body;
|};

# Represents a client error HTTP response.
public type ErrorResponseBadRequest record {|
    *http:BadRequest;
    ErrorResponseBody body;
|};

# Represents a server error HTTP response.
public type ErrorResponseInternalServerError record {|
    *http:InternalServerError;
    ErrorResponseBody body;
|};

# Defines a response type that can represent various success or failure scenarios.
public type SuccessResponseType SuccessResponseWithoutOperations|SuccessResponseWithOperations|SuccessResponseWithRedirection|SuccessResponseWithFailedValidation|FailureResponse;

# Defines a response type that is under SUCCESS status without operations.
public type SuccessResponseWithoutOperations record {
    # Defines the status of the action update
    "SUCCESS" actionStatus;
};

# Defines a response type that is under SUCCESS status with operations.
public type SuccessResponseWithOperations record {
    # Defines the status of the action update
    "SUCCESS" actionStatus;
    # Defines the list operations to be done in relation profile update flow
    Operation[] operations;
};

# Defines a response type that is under INCOMPLETE status with redirection.
public type SuccessResponseWithRedirection record {
    # Defines the status of the action update
    "INCOMPLETE" actionStatus;
    # Reason for the incomplete
    string incompleteReason;
    # A detailed description of the incomplete.
    string incompleteDescription;
    # Defines the redirect operation.
    ResponseRedirectOperation operation;
};

# Defines a response type that is under FAILED status with context.
public type SuccessResponseWithFailedValidation record {
    # Defines the status of the action update
    "FAILED" actionStatus;
    # The status code, as specified in OAuth 2.0 failure response definitions.
    string failureReason;
    # A detailed description of the failure.
    string failureDescription;
    # Defines the list of updating user attribute result.
    Context[] context;
};

# Defines a response type that is under FAILED status without context.
public type FailureResponse record {
    # Indicates the outcome of the request. For an failure operation, this should be set to FAILED.
    "FAILED" actionStatus;
    # The status code, as specified in OAuth 2.0 failure response definitions.
    string failureReason;
    # A detailed description of the failure.
    string failureDescription;
};

# Defines a generic error type for both client and server errors
public type ErrorResponseBody record {
    # Indicates the outcome of the request. For an error operation, this should be set to ERROR.
    "ERROR" actionStatus;
    # The error code.
    string 'error;
    # A detailed description of the error.
    string errorDescription;
};

# Represents the request payload for the profile update flow.
public type RequestBody record {
    # A unique flow correlation identifier that associates with the profile update flow triggered in WSO2 Identity Server.
    string flowId;
    # A unique request correlation identifier that associates with the profile update request received by WSO2 Identity Server.
    string requestId;
    # Specifies the action being triggered, which in this case is PRE_UPDATE_PROFILE.
    "PRE_UPDATE_PROFILE" actionType;
    # Defines the context data related to the event
    Event event;
    # Defines the allowed operations for the user to act on data in the request payload
    AllowedOperations allowedOperations;
};

# Defines the context data related to the event
public type Event record {
    # Defines the initiatorType for the event
    "user"|"admin"|"application" initiatorType;
    # Defines the action exectued for the event
    "update" action;
    # Defines the request data
    Request request;
    # Defines the tenant details for the user
    Tenant tenant;
    # Defines the details of the user
    User user;
    # Defines the details of the organization
    Organization organization?;
    # Defines the details of the userstore
    UserStore userStore;
};

# Any additional parameters included in the profile update request. These may be custom parameters defined by the client or necessary for specific flows
public type Request record {
    # Defines the list of updating user attributes.
    Claims[] claims;
    # Any additional HTTP headers included in the profile update request. These may contain custom information or metadata that the client has sent
    RequestHeaders[] additionalHeaders?;
    # Any additional parameters included in the profile update request. These may be custom parameters defined by the client or necessary for specific flows.
    RequestParams[] additionalParams?;
};

# Defines the user claims selected by the end user that need to be updated during profile update flow
public type Claims record {
    # Identifier of the user claim being updated
    string uri;
    # Updating value of the user claim
    string value;
};

# Defines the structure of HTTP headers , including the header name and its associated values.
public type RequestHeaders record {
    # Name of the request header
    string name;
    # Values defined for a request header
    string[] values;
};

# Defines the structure of request parameters, including their name and corresponding list of values
public type RequestParams record {
    # Name of the request param
    string name;
    # Values defined for a request param
    string[] values;
};

# Represents the tenant under which the profile update request is being processed.
public type Tenant record {
    # The unique numeric identifier of the tenant.
    string id;
    # The domain name of the tenant.
    string name;
};

# Contains information about the user associated with the profile update request, including updated user claims.
public type User record {
    # Defines the unique identifier of the user
    string id;
    # User claims
    UserClaims[] claims;
    # Groups of the user
    string[] groups?;
    # Roles of the user
    string[] roles?;
};

# Includes the additional user claims of the user which can be processed by the external service
public type UserClaims record {
    # Identifier of the user claim
    string uri;
    # Value of the user claim
    string value;
    # Updating value of the user claim
    string updatingvalue?;
};

# Refers to the organization to which the user belongs.
public type Organization record {
    # The unique identifier of the organization.
    string id;
    # Name of the organization used to identify the organization in configurations, user interfaces, etc
    string name;
};

# Indicates the user store in which the user's data is being managed.
public type UserStore record {
    # The unique identifier for the user store.
    string id;
    # User store name used to identify the user store in configuration settings, user interfaces, and administrative tasks
    string name;
};

# Defines the operation
public type AllowedOperations (RedirectOperation | ReplaceOperation | AddOperation | RemoveOperation)[];

# Defines the redirect operation.
public type RedirectOperation record {
    # Defines the operation type
    "redirect" op;
};

# Defines the replace operation for user claims, roles and groups.
public type ReplaceOperation record {
    # Defines the operation type
    "replace" op;
    # Defines modifiable json paths
    ("/user/claims/value/"|"/user/roles/"|"/user/groups/")[] paths;
};

# Defines the add operation for claims, roles and groups.
public type AddOperation record {
    # Defines the operation type
    "add" op;
    # Defines modifiable json paths
    ("/user/claims/"|"/user/roles/"|"/user/groups/")[] paths;
};

# Defines the remove operation for claims, roles and groups.
public type RemoveOperation record {
    # Defines the operation type
    "remove" op;
    # Defines modifiable json paths
    ("/user/claims/"|"/user/roles/"|"/user/groups/")[] paths;
};

# Context of the operation to be done with profile update
public type Operation record {
    # Defines the operation type
    "replace"|"add"|"remove" op;
    # Defines modifiable json paths
    "/user/claims/"|"/user/roles/"|"/user/groups/"|string path;
    string|UserClaims value?;
};

# Defines the structure of the operation included in the SUCCESS response payload regarding redirect operation
public type ResponseRedirectOperation record {
    # Name of the operation type
    "redirect" op;
    # Redirect url sent by the external service
    string url;
};

# Provides the context information for the failures of profile update
public type Context UpdatingClaimResults[];

# Defines the failure or success context for each user claim
public type UpdatingClaimResults record {
    # Identifier of the user claim being updated
    string uri;
    # Status of the update
    "FAILED"|"SUCCESS" status;
    # Message of the updating
    string message;
};