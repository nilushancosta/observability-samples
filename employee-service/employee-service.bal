// Copyright (c) 2021, WSO2 Inc. (http://www.wso2.com). All Rights Reserved.
//
// This software is the property of WSO2 Inc. and its suppliers, if any.
// Dissemination of any information or reproduction of any material contained
// herein in any form is strictly forbidden, unless permitted by WSO2 expressly.
// You may not alter or remove any copyright or other notice from copies of this content.
import ballerina/http;
import ballerina/log;

// HR service related properties
configurable string HR_SERVICE_URL = ?;
// Department service related properties
configurable string DEPARTMENT_SERVICE_URL = ?;

http:Client hrService = check new (HR_SERVICE_URL);

http:Client departmentService = check new (DEPARTMENT_SERVICE_URL);

service / on new http:Listener(8090) {
    resource function get employee/[string employeeId](http:Caller caller) returns error? {
        http:Response hrServiceResponse = <http:Response>check hrService->get("/" + employeeId);
        if (hrServiceResponse.statusCode == http:STATUS_NOT_FOUND) {
            log:printWarn("employee information not found in the hr-service");
            http:Response errorResponse = new;
            errorResponse.statusCode = http:STATUS_NOT_FOUND;
            string payload = <string>check hrServiceResponse.getTextPayload();
            errorResponse.setPayload(payload);
            error? ret = caller->respond(errorResponse);
            if (ret is error) {
                log:printError("responding to client failed", 'error = ret);
            }
            return;
        } else if (hrServiceResponse.statusCode == http:STATUS_INTERNAL_SERVER_ERROR) {
            log:printError("error while connecting to the hr-service");
            http:Response errorResponse = new;
            errorResponse.statusCode = http:STATUS_INTERNAL_SERVER_ERROR;
            string payload = <string>check hrServiceResponse.getTextPayload();
            errorResponse.setPayload(payload);
            error? ret = caller->respond(errorResponse);
            if (ret is error) {
                log:printError("responding to client failed", 'error = ret);
            }
            return;
        }

        json|error employeeDataResponse = hrServiceResponse.getJsonPayload();
        if (employeeDataResponse is error) {
            log:printError("error while retrieving data from the hr-service json payload");
            http:Response errorResponse = new;
            errorResponse.statusCode = http:STATUS_INTERNAL_SERVER_ERROR;
            errorResponse.setPayload("error while retrieving data from the hr-service json payload");
            error? ret = caller->respond(errorResponse);
            if (ret is error) {
                log:printError("responding to client failed", 'error = ret);
            }
            return;
        }

        json employeeDataJson = <json>employeeDataResponse;
        string departmentId = <string>check employeeDataJson.departmentId;
        string firstName = <string>check employeeDataJson.firstName;
        string lastName = <string>check employeeDataJson.lastName;
        string title = <string>check employeeDataJson.title;

        http:Response deptServiceResponse = <http:Response>check departmentService->get("/" + departmentId);
        if (deptServiceResponse.statusCode == http:STATUS_NOT_FOUND) {
            log:printWarn("employee information not found in the department-service");
            http:Response errorResponse = new;
            errorResponse.statusCode = http:STATUS_NOT_FOUND;
            errorResponse.setPayload("requested data not found in department-service");
            error? ret = caller->respond(errorResponse);
            if (ret is error) {
                log:printError("responding to client failed", 'error = ret);
            }
            return;
        }

        json|error departmentDataResponse = deptServiceResponse.getJsonPayload();
        if (departmentDataResponse is error) {
            log:printError("error while retrieving data from the department-service json payload");
            http:Response errorResponse = new;
            errorResponse.statusCode = http:STATUS_INTERNAL_SERVER_ERROR;
            errorResponse.setPayload("error while retrieving data from the department-service json payload");
            error? ret = caller->respond(errorResponse);
            if (ret is error) {
                log:printError("responding to client failed", 'error = ret);
            }
            return;
        } else {
            json departmentDataJson = <json>departmentDataResponse;
            string departmentName = <string>check departmentDataJson.name;
            json summary = {
                name: firstName + " " + lastName,
                title: title,
                department: departmentName
            };

            error? ret = caller->respond(summary);
            if (ret is error) {
                log:printError("responding to client failed", 'error = ret);
            }
        }
    }
}
