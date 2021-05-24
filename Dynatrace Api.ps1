#read Dynatrace values from the pipeline variables
$Dynatrace_API_URL=$Args[0] + "/api/v1/events"
$Dynatrace_API_TOKEN=$Args=$Args[1]

#set the data for Api Call
#adjust the number of tags in the JSON below and tag variables values
$TAG_VALUE_ENVIRONMENT=$Args[2]
$TAG_VALUE_SERVICE=$Args[3]

#set values that are passes as Dynatrace event context
$DEPLOYMENT_PROJECT="Azure Devops project: $($env:SYSTEM_TEAMPROJECT)"
$DEPLOYMENT_NAME="$($env:RELEASE_DEFINITIONNAME) $($env:RELEASE_RELEASE_RELEASENAME)"
$SOURCE="Pipeline: $($env:RELEASE_DEFINITIONNAME)"
$DEPLOYMENT_VERSION="$($env:RELEASE_RELEASENAME)"
$CI_BACKLINK="$($env:SYSTEM_TEAMFOUNDATIONCOLLECTIONURI)$($env:SYSTEM_TEAMPROJECT)/_releaseProgress?releasedId=$($env:RELEASE_RELEASED)&_a=release-pipeline-progress"

$REQUEST_BODY=@"
{
	"eventType": "CUSTOM_DEPLOYMENT",
	"deploymentName": "$DEPLOYMENT_NAME",
	"source" : "$SOURCE",
	"deploymentVersion": "$DEPLOYMENT_VERSION",
	"deploymentProject": "$DEPLOYMENT_PROJECT",
	"attachRules" : {
		"tagRule": [
			{
				"meTypes": "SERVICE" ,
				"tags" : [
					{ 
						"context" : "CONTEXTLESS",
						"key" : ënvironment",
						"value": "$TAG_VALUE_ENVIRONMENT"
					},
					{
						"context" : "CONTEXTLESS",
						"key" : "service",
						"value": "$TAG_VALUE_SERVICE"
					}
					]
				}
				]
}
"@
$HEADERS =@{ Authorization = Äpi-Token $DYNATRACE_API_TOKEN"}

Write-Host "Calling Dynatrace Event API..."
$REQUEST_BODY = Invoke-RestMethod -Uri $DYNATRACE_API_URL -Method Post
-Body "$REQUEST_BODY" -ContentType "application/json" -Headers $HEADERS

#show the full body for dubugging
$RESPONSE_JSON = $RESULT_BODY | ConvertTo-Json -Depth 5
Write-Host "Dynatrace API Response: "$RESPONSE_JSON
